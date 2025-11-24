'use client';

import type { ReactElement } from 'react';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import type { Conversation } from '@/types/conversation';
import { Calendar as CalendarIcon, MessageCircle, Sparkles } from 'lucide-react';

interface CalendarViewProps {
  conversations: Conversation[];
  userName: string;
}

export function CalendarView({ conversations, userName }: CalendarViewProps): ReactElement {
  const today = new Date().toISOString().split('T')[0];
  const todayConversations = conversations.filter((conv: Conversation) => conv.date === today);

  const daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const now = new Date();
  const currentMonth = now.getMonth();
  const currentYear = now.getFullYear();
  
  const firstDayOfMonth = new Date(currentYear, currentMonth, 1);
  const lastDayOfMonth = new Date(currentYear, currentMonth + 1, 0);
  const startingDayOfWeek = firstDayOfMonth.getDay();
  const daysInMonth = lastDayOfMonth.getDate();

  const calendarDays: (number | null)[] = [];
  for (let i = 0; i < startingDayOfWeek; i++) {
    calendarDays.push(null);
  }
  for (let day = 1; day <= daysInMonth; day++) {
    calendarDays.push(day);
  }

  const getConversationsForDay = (day: number): number => {
    const dateStr = new Date(currentYear, currentMonth, day).toISOString().split('T')[0];
    return conversations.filter((conv: Conversation) => conv.date === dateStr).length;
  };

  const monthName = now.toLocaleDateString('en-US', { month: 'long', year: 'numeric' });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-gradient-to-r from-purple-50 to-blue-50 rounded-2xl p-6 shadow-lg">
        <div className="flex items-center gap-3 mb-3">
          <div className="h-12 w-12 bg-gradient-to-br from-purple-500 to-blue-500 rounded-full flex items-center justify-center">
            <CalendarIcon className="h-6 w-6 text-white" />
          </div>
          <h2 className="text-3xl md:text-4xl font-bold bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
            Your Memory Calendar
          </h2>
        </div>
        <p className="text-xl md:text-2xl text-gray-700">
          Track your daily conversations, {userName}
        </p>
      </div>

      {/* Calendar Grid */}
      <Card className="border-0 shadow-2xl bg-white overflow-hidden">
        <div className="bg-gradient-to-r from-purple-600 to-blue-600 text-white p-6">
          <h3 className="text-3xl font-bold text-center">{monthName}</h3>
        </div>
        <CardContent className="p-6">
          {/* Days of Week Header */}
          <div className="grid grid-cols-7 gap-2 mb-4">
            {daysOfWeek.map((day: string) => (
              <div
                key={day}
                className="text-center text-xl md:text-2xl font-bold text-purple-700 bg-purple-50 rounded-lg p-2"
              >
                {day}
              </div>
            ))}
          </div>

          {/* Calendar Days */}
          <div className="grid grid-cols-7 gap-2">
            {calendarDays.map((day: number | null, index: number) => {
              if (day === null) {
                return <div key={`empty-${index}`} className="aspect-square" />;
              }

              const isToday = day === now.getDate();
              const conversationCount = getConversationsForDay(day);
              const hasConversations = conversationCount > 0;

              return (
                <div
                  key={day}
                  className={`aspect-square rounded-xl p-2 flex flex-col items-center justify-center text-center transition-all duration-300 transform hover:scale-105 ${
                    isToday
                      ? 'bg-gradient-to-br from-purple-500 to-pink-500 text-white shadow-xl ring-4 ring-purple-300'
                      : hasConversations
                      ? 'bg-gradient-to-br from-blue-100 to-purple-100 text-gray-800 border-2 border-purple-300 shadow-md hover:shadow-lg'
                      : 'bg-gray-50 text-gray-600 hover:bg-gray-100 border border-gray-200'
                  }`}
                >
                  <span className={`text-2xl md:text-3xl font-bold ${isToday ? 'text-white' : ''}`}>
                    {day}
                  </span>
                  {hasConversations && (
                    <Badge 
                      className={`mt-1 text-xs ${
                        isToday 
                          ? 'bg-white text-purple-700' 
                          : 'bg-purple-600 text-white'
                      }`}
                    >
                      {conversationCount}
                    </Badge>
                  )}
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      {/* Today's Conversations */}
      <Card className="border-0 shadow-xl bg-gradient-to-br from-pink-50 to-purple-50">
        <CardContent className="p-6">
          <div className="flex items-center gap-2 mb-4">
            <Sparkles className="h-6 w-6 text-purple-600" />
            <h3 className="text-2xl md:text-3xl font-bold text-purple-900">
              Today&apos;s Conversations
            </h3>
          </div>
          {todayConversations.length === 0 ? (
            <p className="text-xl md:text-2xl text-gray-600 text-center py-8">
              💬 No conversations recorded today yet. Start recording to capture your memories!
            </p>
          ) : (
            <div className="space-y-4">
              {todayConversations.map((conv: Conversation) => (
                <Card key={conv.id} className="border-2 border-purple-200 bg-white shadow-md hover:shadow-xl transition-all duration-300">
                  <CardContent className="p-4">
                    <div className="flex items-start gap-3">
                      <div className="h-10 w-10 bg-gradient-to-br from-purple-500 to-pink-500 rounded-full flex items-center justify-center flex-shrink-0">
                        <MessageCircle className="h-5 w-5 text-white" />
                      </div>
                      <div className="flex-1">
                        <p className="text-lg md:text-xl font-semibold text-purple-900">
                          {conv.time}
                          {conv.personName && (
                            <span className="text-gray-700 ml-2">• with {conv.personName}</span>
                          )}
                        </p>
                        <p className="text-base md:text-lg text-gray-700 mt-1">
                          {conv.summary}
                        </p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
