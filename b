'use client'
import { useState, useEffect } from 'react';
import type { ReactElement } from 'react';
import { Card } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { LoginScreen } from '@/components/login-screen';
import { CalendarView } from '@/components/calendar-view';
import { RecordingView } from '@/components/recording-view';
import { ReflectView } from '@/components/reflect-view';
import { SettingsView } from '@/components/settings-view';
import { useAuth } from '@/hooks/use-auth';
import { useConversations } from '@/hooks/use-conversations';
import { Calendar, Mic, BookOpen, Settings } from 'lucide-react';
import { sdk } from "@farcaster/miniapp-sdk";
import { useAddMiniApp } from "@/hooks/useAddMiniApp";
import { useQuickAuth } from "@/hooks/useQuickAuth";
import { useIsInFarcaster } from "@/hooks/useIsInFarcaster";

export default function Home(): ReactElement {
    const { addMiniApp } = useAddMiniApp();
    const isInFarcaster = useIsInFarcaster()
    useQuickAuth(isInFarcaster)
    useEffect(() => {
      const tryAddMiniApp = async () => {
        try {
          await addMiniApp()
        } catch (error) {
          console.error('Failed to add mini app:', error)
        }

      }

    

      tryAddMiniApp()
    }, [addMiniApp])
    useEffect(() => {
      const initializeFarcaster = async () => {
        try {
          await new Promise(resolve => setTimeout(resolve, 100))
          
          if (document.readyState !== 'complete') {
            await new Promise<void>(resolve => {
              if (document.readyState === 'complete') {
                resolve()
              } else {
                window.addEventListener('load', () => resolve(), { once: true })
              }

            })
          }

    

          await sdk.actions.ready()
          console.log('Farcaster SDK initialized successfully - app fully loaded')
        } catch (error) {
          console.error('Failed to initialize Farcaster SDK:', error)
          
          setTimeout(async () => {
            try {
              await sdk.actions.ready()
              console.log('Farcaster SDK initialized on retry')
            } catch (retryError) {
              console.error('Farcaster SDK retry failed:', retryError)
            }

          }, 1000)
        }

      }

    

      initializeFarcaster()
    }, [])
  const { currentUser, hasAccount, login, createAccount, isAuthenticated } = useAuth();
  const { conversations } = useConversations(currentUser?.userId);

  const handleLogin = (password: string): boolean => {
    return login(password);
  };

  const handleCreateAccount = (name: string, password: string): void => {
    const newUser = createAccount(name, password);
    // Auto-login after creating account
    login(password);
  };

  // Show login screen if not authenticated
  if (!isAuthenticated || !currentUser) {
    return (
      <LoginScreen 
        hasAccount={hasAccount}
        onLogin={handleLogin}
        onCreateAccount={handleCreateAccount}
      />
    );
  }

  const userName = currentUser.userName;

  const today = new Date().toLocaleDateString('en-US', { 
    weekday: 'long', 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  });

  const getGreeting = (): string => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-100 via-pink-100 to-blue-100 text-black p-4 pt-16 md:p-6">
      <div className="max-w-4xl mx-auto">
        {/* Header with gradient */}
        <header className="mb-6 bg-gradient-to-r from-purple-600 to-pink-600 rounded-2xl p-6 md:p-8 shadow-2xl text-white transform hover:scale-[1.02] transition-transform duration-300">
          <h1 className="text-4xl md:text-5xl font-bold mb-2 drop-shadow-lg">
            {getGreeting()}, {userName}! 👋
          </h1>
          <p className="text-2xl md:text-3xl opacity-90">{today}</p>
        </header>

        {/* Main Content Card */}
        <Card className="bg-white/95 backdrop-blur-sm border-0 shadow-2xl rounded-2xl overflow-hidden">
          <Tabs defaultValue="calendar" className="w-full">
            <TabsList className="grid w-full grid-cols-4 h-20 bg-gradient-to-r from-purple-50 to-pink-50 border-b-4 border-purple-200">
              <TabsTrigger 
                value="calendar" 
                className="text-lg md:text-xl font-bold data-[state=active]:bg-white data-[state=active]:shadow-lg data-[state=active]:border-b-4 data-[state=active]:border-purple-600 flex flex-col items-center gap-1 transition-all duration-300"
              >
                <Calendar className="h-6 w-6" />
                <span className="hidden sm:inline">Calendar</span>
              </TabsTrigger>
              <TabsTrigger 
                value="record" 
                className="text-lg md:text-xl font-bold data-[state=active]:bg-white data-[state=active]:shadow-lg data-[state=active]:border-b-4 data-[state=active]:border-pink-600 flex flex-col items-center gap-1 transition-all duration-300"
              >
                <Mic className="h-6 w-6" />
                <span className="hidden sm:inline">Record</span>
              </TabsTrigger>
              <TabsTrigger 
                value="reflect" 
                className="text-lg md:text-xl font-bold data-[state=active]:bg-white data-[state=active]:shadow-lg data-[state=active]:border-b-4 data-[state=active]:border-blue-600 flex flex-col items-center gap-1 transition-all duration-300"
              >
                <BookOpen className="h-6 w-6" />
                <span className="hidden sm:inline">Reflect</span>
              </TabsTrigger>
              <TabsTrigger 
                value="settings" 
                className="text-lg md:text-xl font-bold data-[state=active]:bg-white data-[state=active]:shadow-lg data-[state=active]:border-b-4 data-[state=active]:border-green-600 flex flex-col items-center gap-1 transition-all duration-300"
              >
                <Settings className="h-6 w-6" />
                <span className="hidden sm:inline">Settings</span>
              </TabsTrigger>
            </TabsList>

            <TabsContent value="calendar" className="p-6 animate-in fade-in-50 duration-500">
              <CalendarView conversations={conversations} userName={userName} />
            </TabsContent>

            <TabsContent value="record" className="p-6 animate-in fade-in-50 duration-500">
              <RecordingView userName={userName} userId={currentUser?.userId} />
            </TabsContent>

            <TabsContent value="reflect" className="p-6 animate-in fade-in-50 duration-500">
              <ReflectView conversations={conversations} userName={userName} />
            </TabsContent>

            <TabsContent value="settings" className="p-6 animate-in fade-in-50 duration-500">
              <SettingsView currentUserId={currentUser?.userId} />
            </TabsContent>
          </Tabs>
        </Card>
      </div>
    </div>
  );
}
