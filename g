'use client';

import type { ReactElement } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Separator } from '@/components/ui/separator';
import { Settings, Volume2, Type, Palette, Trash2, Shield, Lock } from 'lucide-react';
import { useConversations } from '@/hooks/use-conversations';
import { useAuth } from '@/hooks/use-auth';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { useState } from 'react';

interface SettingsViewProps {
  currentUserId?: string;
}

export function SettingsView({ currentUserId }: SettingsViewProps): ReactElement {
  const { clearAllConversations } = useConversations(currentUserId);
  const { deleteAccount, currentUser } = useAuth();
  const [showDeleteConfirm, setShowDeleteConfirm] = useState<boolean>(false);

  const handleClearData = (): void => {
    if (window.confirm('Are you sure you want to delete all your conversation history? This cannot be undone.')) {
      clearAllConversations();
      alert('All conversation history has been cleared.');
    }
  };

  const handleDeleteAccount = (): void => {
    if (showDeleteConfirm) {
      if (window.confirm('This will permanently delete your account and all data. Are you absolutely sure?')) {
        deleteAccount();
        // No alert - let the app naturally redirect to create account screen
      }
    } else {
      setShowDeleteConfirm(true);
      setTimeout(() => setShowDeleteConfirm(false), 5000);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <div className="h-12 w-12 bg-gradient-to-br from-green-500 to-emerald-500 rounded-full flex items-center justify-center">
          <Settings className="h-6 w-6 text-white" />
        </div>
        <h2 className="text-3xl md:text-4xl font-bold bg-gradient-to-r from-green-600 to-emerald-600 bg-clip-text text-transparent">
          Settings
        </h2>
      </div>

      {/* Account Info */}
      <Card className="border-0 shadow-xl bg-gradient-to-br from-blue-50 to-cyan-50">
        <CardHeader>
          <CardTitle className="text-2xl flex items-center gap-2">
            <Shield className="h-6 w-6 text-blue-600" />
            Account Information
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="bg-white p-4 rounded-lg border-2 border-blue-200">
            <p className="text-lg text-gray-600">Your Name:</p>
            <p className="text-2xl font-bold text-gray-800">{currentUser?.userName}</p>
          </div>
          <div className="bg-white p-4 rounded-lg border-2 border-blue-200">
            <div className="flex items-start gap-3">
              <Lock className="h-6 w-6 text-blue-600 mt-1 flex-shrink-0" />
              <div>
                <p className="text-lg font-semibold text-gray-800">Session Security</p>
                <p className="text-base text-gray-600 mt-1">
                  You'll stay logged in during your current session. When you close and reopen the app, you'll need to enter your password again for security.
                </p>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Accessibility Features */}
      <Card className="border-0 shadow-xl bg-gradient-to-br from-purple-50 to-pink-50">
        <CardHeader>
          <CardTitle className="text-2xl flex items-center gap-2">
            <Palette className="h-6 w-6 text-purple-600" />
            Accessibility Features
          </CardTitle>
          <CardDescription className="text-lg">
            MindTrack is designed with accessibility in mind
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-3">
            <div className="flex items-start gap-3 bg-white p-4 rounded-lg border-2 border-purple-200">
              <Volume2 className="h-6 w-6 text-purple-600 mt-1 flex-shrink-0" />
              <div>
                <h3 className="text-xl font-bold">Text-to-Speech</h3>
                <p className="text-lg text-gray-700">
                  Tap the speaker icon on any conversation to hear it read aloud
                </p>
              </div>
            </div>
            
            <div className="flex items-start gap-3 bg-white p-4 rounded-lg border-2 border-purple-200">
              <Type className="h-6 w-6 text-purple-600 mt-1 flex-shrink-0" />
              <div>
                <h3 className="text-xl font-bold">Large Text</h3>
                <p className="text-lg text-gray-700">
                  All text is displayed in extra-large, easy-to-read fonts
                </p>
              </div>
            </div>
            
            <div className="flex items-start gap-3 bg-white p-4 rounded-lg border-2 border-purple-200">
              <Palette className="h-6 w-6 text-purple-600 mt-1 flex-shrink-0" />
              <div>
                <h3 className="text-xl font-bold">High Contrast</h3>
                <p className="text-lg text-gray-700">
                  Black text on white backgrounds for maximum readability
                </p>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Data Management */}
      <Card className="border-0 shadow-xl bg-gradient-to-br from-orange-50 to-red-50">
        <CardHeader>
          <CardTitle className="text-2xl flex items-center gap-2">
            <Trash2 className="h-6 w-6 text-red-600" />
            Data Management
          </CardTitle>
          <CardDescription className="text-lg">
            Manage your stored conversation data
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="bg-white p-4 rounded-lg border-2 border-orange-200">
            <p className="text-lg text-gray-700 mb-4">
              All your conversations are stored securely on your device only. No data is sent to external servers.
            </p>
          </div>
          
          <Button
            onClick={handleClearData}
            variant="outline"
            className="w-full h-14 text-xl font-semibold border-4 border-orange-400 hover:bg-orange-50"
          >
            <Trash2 className="h-5 w-5 mr-2" />
            Clear All Conversation History
          </Button>

          <Separator className="my-4" />

          {showDeleteConfirm && (
            <Alert className="border-4 border-red-500 bg-red-50">
              <AlertDescription className="text-lg text-red-800">
                <strong>Warning:</strong> Click "Delete Account" again to permanently delete your account and all data!
              </AlertDescription>
            </Alert>
          )}

          <Button
            onClick={handleDeleteAccount}
            variant="destructive"
            className="w-full h-14 text-xl font-semibold bg-red-600 hover:bg-red-700"
          >
            <Trash2 className="h-5 w-5 mr-2" />
            {showDeleteConfirm ? 'Click Again to Confirm Account Deletion' : 'Delete Account'}
          </Button>
        </CardContent>
      </Card>

      {/* Privacy Information */}
      <Card className="border-0 shadow-xl bg-gradient-to-br from-green-50 to-blue-50">
        <CardHeader>
          <CardTitle className="text-2xl">Privacy & Security</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-lg text-gray-700">
            🔒 Your data is private and secure. All conversations are stored locally on your device and are never shared or uploaded to any server. Your account is protected with a password that only you know. The app stays logged in during your session for convenience, but requires your password when reopened.
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
