'use client';

import { useState } from 'react';
import type { ReactElement } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Volume2, Search, Clock, User, Tag, Calendar as CalendarIcon } from 'lucide-react';
import type { Conversation } from '@/types/conversation';
import { useSpeech } from '@/hooks/use-speech';

interface ReflectViewProps {
  conversations: Conversation[];
  userName: string;
}

export function ReflectView({ conversations, userName }: ReflectViewProps): ReactElement {
  const [searchTerm, setSearchTerm] = useState<string>('');
  const { speak, isSpeaking, stop } = useSpeech();

  const sortedConversations = [...conversations].sort((a, b) => {
    const dateA = new Date(`${a.date} ${a.time}`).getTime();
    const dateB = new Date(`${b.date} ${b.time}`).getTime();
    return dateB - dateA;
  });

  const filteredConversations = sortedConversations.filter((conv: Conversation) => {
    const searchLower = searchTerm.toLowerCase();
    return (
      conv.summary.toLowerCase().includes(searchLower) ||
      conv.personName?.toLowerCase().includes(searchLower) ||
      conv.topics?.some((topic: string) => topic.toLowerCase().includes(searchLower))
    );
  });

  const handleSpeak = (text: string): void => {
    if (isSpeaking) {
      stop();
    } else {
      speak(text);
    }
  };

  const groupByDate = (convs: Conversation[]): Record<string, Conversation[]> => {
    const grouped: Record<string, Conversation[]> = {};
    convs.forEach((conv: Conversation) => {
      if (!grouped[conv.date]) {
        grouped[conv.date] = [];
      }
      grouped[conv.date].push(conv);
    });
    return grouped;
  };

  const groupedConversations = groupByDate(filteredConversations);
  const dateKeys = Object.keys(groupedConversations).sort((a, b) => b.localeCompare(a));

  return (
    <div className="space-y-6">
      <div className="bg-gradient-to-r from-blue-50 to-purple-50 rounded-2xl p-6 shadow-lg">
        <div className="flex items-center gap-3 mb-2">
          <div className="h-12 w-12 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full flex items-center justify-center">
            <CalendarIcon className="h-6 w-6 text-white" />
          </div>
          <h2 className="text-3xl md:text-4xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
            Reflect on Your Conversations
          </h2>
        </div>
        <p className="text-xl md:text-2xl text-gray-700 ml-15">
          {userName}, here&apos;s what you&apos;ve talked about ✨
        </p>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-8 w-8 text-purple-500" />
        <Input
          type="text"
          placeholder="Search conversations, people, or topics..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="text-xl md:text-2xl h-16 pl-16 border-4 border-purple-300 focus:border-purple-500 shadow-lg bg-white transition-all duration-300"
        />
      </div>

      {/* Conversations */}
      {filteredConversations.length === 0 ? (
        <Card className="border-0 shadow-xl bg-gradient-to-br from-gray-50 to-gray-100">
          <CardContent className="p-8">
            <p className="text-2xl md:text-3xl text-gray-600 text-center">
              {searchTerm 
                ? '🔍 No conversations match your search' 
                : '📝 No conversations recorded yet. Start recording to build your memory!'
              }
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-6">
          {dateKeys.map((dateStr: string) => {
            const date = new Date(dateStr);
            const isToday = dateStr === new Date().toISOString().split('T')[0];
            const isYesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0] === dateStr;
            
            let dateLabel = date.toLocaleDateString('en-US', { 
              weekday: 'long', 
              year: 'numeric', 
              month: 'long', 
              day: 'numeric' 
            });
            
            if (isToday) dateLabel = '🌟 Today';
            else if (isYesterday) dateLabel = '🕐 Yesterday';

            const gradientColors = isToday 
              ? 'from-purple-600 to-pink-600' 
              : isYesterday 
              ? 'from-blue-600 to-cyan-600'
              : 'from-gray-600 to-gray-700';

            return (
              <div key={dateStr} className="space-y-4">
                <div className={`bg-gradient-to-r ${gradientColors} text-white rounded-xl p-4 shadow-lg`}>
                  <h3 className="text-2xl md:text-3xl font-bold flex items-center gap-2">
                    <CalendarIcon className="h-6 w-6" />
                    {dateLabel}
                  </h3>
                </div>
                {groupedConversations[dateStr].map((conversation: Conversation) => (
                  <Card 
                    key={conversation.id} 
                    className="border-0 shadow-xl bg-gradient-to-br from-white to-gray-50 hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-1"
                  >
                    <CardHeader className="pb-4 bg-gradient-to-r from-purple-50 to-pink-50 rounded-t-xl">
                      <div className="flex justify-between items-start">
                        <div className="flex-1 space-y-2">
                          <CardTitle className="text-2xl md:text-3xl font-bold flex items-center gap-2 text-purple-900">
                            <Clock className="h-6 w-6 text-purple-600" />
                            {conversation.time}
                          </CardTitle>
                          {conversation.personName && (
                            <p className="text-xl md:text-2xl text-gray-700 flex items-center gap-2 ml-8">
                              <User className="h-5 w-5 text-pink-600" />
                              <span className="font-semibold">With:</span> {conversation.personName}
                            </p>
                          )}
                        </div>
                        <Button
                          size="lg"
                          variant="outline"
                          className="border-4 border-purple-300 h-16 w-16 bg-white hover:bg-purple-50 hover:border-purple-500 transition-all duration-300"
                          onClick={() => handleSpeak(conversation.summary)}
                          title="Read aloud"
                        >
                          <Volume2 className={`h-8 w-8 ${isSpeaking ? 'text-purple-600 animate-pulse' : 'text-gray-700'}`} />
                        </Button>
                      </div>
                    </CardHeader>
                    <CardContent className="pt-6">
                      <p className="text-xl md:text-2xl leading-relaxed text-gray-800">
                        {conversation.summary}
                      </p>
                      {conversation.topics && conversation.topics.length > 0 && (
                        <div className="flex flex-wrap gap-2 mt-4">
                          {conversation.topics.map((topic: string, index: number) => (
                            <span
                              key={index}
                              className="bg-gradient-to-r from-blue-100 to-purple-100 text-purple-800 px-4 py-2 rounded-full text-lg font-semibold border-2 border-purple-300 shadow-md flex items-center gap-1 hover:scale-105 transition-transform duration-300"
                            >
                              <Tag className="h-4 w-4" />
                              {topic}
                            </span>
                          ))}
                        </div>
                      )}
                    </CardContent>
                  </Card>
                ))}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
