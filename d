'use client';

import { useState, useEffect } from 'react';
import type { ReactElement, FormEvent } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { User, Lock, UserPlus, AlertCircle, LogIn } from 'lucide-react';

interface LoginScreenProps {
  hasAccount: boolean;
  onLogin: (password: string) => boolean;
  onCreateAccount: (name: string, password: string) => void;
}

export function LoginScreen({ hasAccount, onLogin, onCreateAccount }: LoginScreenProps): ReactElement {
  const [isCreatingAccount, setIsCreatingAccount] = useState<boolean>(!hasAccount);
  const [password, setPassword] = useState<string>('');
  const [newName, setNewName] = useState<string>('');
  const [newPassword, setNewPassword] = useState<string>('');
  const [confirmPassword, setConfirmPassword] = useState<string>('');
  const [error, setError] = useState<string>('');

  // Update isCreatingAccount when hasAccount changes (e.g., after account deletion)
  useEffect(() => {
    setIsCreatingAccount(!hasAccount);
    // Clear form fields when switching
    setPassword('');
    setNewName('');
    setNewPassword('');
    setConfirmPassword('');
    setError('');
  }, [hasAccount]);

  const handleLogin = (e: FormEvent<HTMLFormElement>): void => {
    e.preventDefault();
    setError('');

    if (!password) {
      setError('Please enter your password');
      return;
    }

    const success = onLogin(password);
    if (!success) {
      setError('Incorrect password. Please try again.');
      setPassword('');
    }
  };

  const handleCreateAccount = (e: FormEvent<HTMLFormElement>): void => {
    e.preventDefault();
    setError('');

    if (!newName.trim()) {
      setError('Please enter your name');
      return;
    }

    if (newPassword.length < 6) {
      setError('Password must be at least 6 characters');
      return;
    }

    if (newPassword !== confirmPassword) {
      setError('Passwords do not match');
      return;
    }

    try {
      onCreateAccount(newName.trim(), newPassword);
    } catch (err) {
      if (err instanceof Error) {
        setError(err.message);
      }
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-100 via-pink-100 to-blue-100 flex items-center justify-center p-4 pt-16">
      <Card className="w-full max-w-2xl border-0 shadow-2xl bg-white/95 backdrop-blur-sm">
        <CardHeader className="text-center space-y-4 pb-8 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-t-lg">
          <CardTitle className="text-5xl md:text-6xl font-bold drop-shadow-lg">
            Welcome to MindTrack 🧠
          </CardTitle>
          <CardDescription className="text-2xl md:text-3xl text-white/90">
            Your personal conversation memory assistant
          </CardDescription>
        </CardHeader>
        
        <CardContent className="p-8">
          {error && (
            <Alert className="mb-6 border-4 border-red-400 bg-gradient-to-r from-red-50 to-rose-50">
              <AlertCircle className="h-6 w-6 text-red-600" />
              <AlertDescription className="text-xl text-red-800 ml-2 font-semibold">
                {error}
              </AlertDescription>
            </Alert>
          )}

          {isCreatingAccount ? (
            <form onSubmit={handleCreateAccount} className="space-y-6">
              <div className="text-center mb-6">
                <div className="inline-block bg-gradient-to-br from-purple-500 to-pink-500 p-4 rounded-full mb-4">
                  <UserPlus className="h-12 w-12 text-white" />
                </div>
                <h3 className="text-3xl font-bold text-gray-800">Create Your Account</h3>
                <p className="text-lg text-gray-600 mt-2">One account per device</p>
              </div>

              <div className="space-y-3">
                <Label htmlFor="newName" className="text-2xl font-bold flex items-center gap-2">
                  <User className="h-6 w-6 text-purple-600" />
                  Your Name
                </Label>
                <Input
                  id="newName"
                  type="text"
                  value={newName}
                  onChange={(e) => setNewName(e.target.value)}
                  placeholder="Enter your name"
                  className="text-2xl h-16 border-4 border-purple-300 focus:border-purple-500"
                  autoFocus
                />
              </div>

              <div className="space-y-3">
                <Label htmlFor="newPassword" className="text-2xl font-bold flex items-center gap-2">
                  <Lock className="h-6 w-6 text-pink-600" />
                  Create Password (min 6 characters)
                </Label>
                <Input
                  id="newPassword"
                  type="password"
                  value={newPassword}
                  onChange={(e) => setNewPassword(e.target.value)}
                  placeholder="Enter password"
                  className="text-2xl h-16 border-4 border-pink-300 focus:border-pink-500"
                />
              </div>

              <div className="space-y-3">
                <Label htmlFor="confirmPassword" className="text-2xl font-bold flex items-center gap-2">
                  <Lock className="h-6 w-6 text-blue-600" />
                  Confirm Password
                </Label>
                <Input
                  id="confirmPassword"
                  type="password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  placeholder="Re-enter password"
                  className="text-2xl h-16 border-4 border-blue-300 focus:border-blue-500"
                />
              </div>

              <Button 
                type="submit" 
                className="w-full h-16 text-2xl font-bold bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 text-white shadow-xl"
                disabled={!newName.trim() || newPassword.length < 6 || newPassword !== confirmPassword}
              >
                <UserPlus className="h-6 w-6 mr-2" />
                Create Account
              </Button>

              {hasAccount && (
                <Button
                  type="button"
                  variant="outline"
                  className="w-full h-14 text-xl font-semibold border-4"
                  onClick={() => {
                    setIsCreatingAccount(false);
                    setError('');
                    setNewName('');
                    setNewPassword('');
                    setConfirmPassword('');
                  }}
                >
                  Back to Login
                </Button>
              )}
            </form>
          ) : (
            <form onSubmit={handleLogin} className="space-y-6">
              <div className="text-center mb-6">
                <div className="inline-block bg-gradient-to-br from-blue-500 to-purple-500 p-4 rounded-full mb-4">
                  <LogIn className="h-12 w-12 text-white" />
                </div>
                <h3 className="text-3xl font-bold text-gray-800">Welcome Back!</h3>
                <p className="text-lg text-gray-600 mt-2">Enter your password to continue</p>
              </div>

              <div className="space-y-3">
                <Label htmlFor="password" className="text-2xl font-bold flex items-center gap-2">
                  <Lock className="h-6 w-6 text-purple-600" />
                  Password
                </Label>
                <Input
                  id="password"
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Enter your password"
                  className="text-2xl h-16 border-4 border-purple-300 focus:border-purple-500"
                  autoFocus
                />
              </div>

              <Button 
                type="submit" 
                className="w-full h-16 text-2xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white shadow-xl"
                disabled={!password}
              >
                <LogIn className="h-6 w-6 mr-2" />
                Login
              </Button>
            </form>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
