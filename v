'use client';

import { useState, useEffect } from 'react';

interface UserSettings {
  userName: string;
  setUserName: (name: string) => void;
}

export function useUserSettings(userId?: string): UserSettings {
  const [userName, setUserNameState] = useState<string>('');

  const storageKey = userId ? `mindtrack_settings_${userId}` : 'mindtrack_username';

  useEffect(() => {
    if (!userId) {
      setUserNameState('');
      return;
    }

    const stored = localStorage.getItem(storageKey);
    if (stored) {
      try {
        const settings = JSON.parse(stored) as { userName: string };
        setUserNameState(settings.userName || '');
      } catch {
        // Fallback for old format
        setUserNameState(stored);
      }
    }
  }, [userId, storageKey]);

  const setUserName = (name: string): void => {
    if (!userId) return;

    setUserNameState(name);
    const settings = { userName: name };
    localStorage.setItem(storageKey, JSON.stringify(settings));
  };

  return { userName, setUserName };
}
