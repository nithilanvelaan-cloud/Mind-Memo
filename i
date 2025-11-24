'use client';

import { useState, useEffect } from 'react';
import type { User, UserAccount, SessionState } from '@/types/user';

interface UseAuthReturn {
  currentUser: UserAccount | null;
  hasAccount: boolean;
  login: (password: string) => boolean;
  logout: () => void;
  createAccount: (name: string, password: string) => User;
  deleteAccount: () => void;
  isAuthenticated: boolean;
  needsPassword: boolean;
}

const USER_KEY = 'mindtrack_user';
const SESSION_KEY = 'mindtrack_session';

export function useAuth(): UseAuthReturn {
  const [currentUser, setCurrentUser] = useState<UserAccount | null>(null);
  const [storedUser, setStoredUser] = useState<User | null>(null);
  const [needsPassword, setNeedsPassword] = useState<boolean>(true);

  // Load user and check session on mount
  useEffect(() => {
    // Load the stored user (if exists)
    const userData = localStorage.getItem(USER_KEY);
    if (userData) {
      try {
        const parsed = JSON.parse(userData) as User;
        setStoredUser(parsed);
      } catch (error) {
        console.error('Error parsing stored user:', error);
      }
    }

    // Check if there's an active session
    const sessionData = sessionStorage.getItem(SESSION_KEY);
    if (sessionData) {
      try {
        const session = JSON.parse(sessionData) as SessionState;
        
        // Check if session is still valid (less than 24 hours old)
        const lastActivity = new Date(session.lastActivity);
        const now = new Date();
        const hoursSinceActivity = (now.getTime() - lastActivity.getTime()) / (1000 * 60 * 60);
        
        if (session.isActive && hoursSinceActivity < 24 && userData) {
          // Session is valid, restore user
          const parsed = JSON.parse(userData) as User;
          const userAccount: UserAccount = {
            userId: parsed.id,
            userName: parsed.name,
          };
          setCurrentUser(userAccount);
          setNeedsPassword(false);
          
          // Update last activity
          updateSessionActivity();
        } else {
          // Session expired or invalid
          sessionStorage.removeItem(SESSION_KEY);
          setNeedsPassword(true);
        }
      } catch (error) {
        console.error('Error parsing session:', error);
        sessionStorage.removeItem(SESSION_KEY);
      }
    }
  }, []);

  const updateSessionActivity = (): void => {
    const session: SessionState = {
      isActive: true,
      lastActivity: new Date().toISOString(),
    };
    sessionStorage.setItem(SESSION_KEY, JSON.stringify(session));
  };

  const createAccount = (name: string, password: string): User => {
    // Only allow one account per device
    if (storedUser) {
      throw new Error('An account already exists on this device');
    }

    const newUser: User = {
      id: Date.now().toString(),
      name: name.trim(),
      password,
      createdAt: new Date().toISOString(),
    };

    setStoredUser(newUser);
    localStorage.setItem(USER_KEY, JSON.stringify(newUser));

    return newUser;
  };

  const login = (password: string): boolean => {
    if (!storedUser) {
      return false;
    }

    if (storedUser.password !== password) {
      return false;
    }

    const userAccount: UserAccount = {
      userId: storedUser.id,
      userName: storedUser.name,
    };

    setCurrentUser(userAccount);
    setNeedsPassword(false);
    
    // Create active session
    updateSessionActivity();
    
    return true;
  };

  const logout = (): void => {
    setCurrentUser(null);
    setNeedsPassword(true);
    sessionStorage.removeItem(SESSION_KEY);
  };

  const deleteAccount = (): void => {
    if (!storedUser) return;

    // Remove all user data
    localStorage.removeItem(USER_KEY);
    localStorage.removeItem(`mindtrack_conversations_${storedUser.id}`);
    localStorage.removeItem(`mindtrack_settings_${storedUser.id}`);
    sessionStorage.removeItem(SESSION_KEY);

    // Reset state
    setStoredUser(null);
    setCurrentUser(null);
    setNeedsPassword(true);
  };

  // Update session activity when user is active
  useEffect(() => {
    if (currentUser && !needsPassword) {
      // Update session every 5 minutes of activity
      const interval = setInterval(() => {
        updateSessionActivity();
      }, 5 * 60 * 1000);

      return () => clearInterval(interval);
    }
  }, [currentUser, needsPassword]);

  return {
    currentUser,
    hasAccount: storedUser !== null,
    login,
    logout,
    createAccount,
    deleteAccount,
    isAuthenticated: currentUser !== null && !needsPassword,
    needsPassword,
  };
}
