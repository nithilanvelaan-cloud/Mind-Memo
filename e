'use client';

import { useState, useEffect } from 'react';
import type { ReactElement } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Mic, Square, AlertCircle, Save, User, MessageSquare, CheckCircle2, Sparkles } from 'lucide-react';
import { useConversations } from '@/hooks/use-conversations';
import { useSpeechRecognition } from '@/hooks/use-speech-recognition';

interface RecordingViewProps {
  userName: string;
  userId?: string;
}

export function RecordingView({ userName, userId }: RecordingViewProps): ReactElement {
  const { addConversation } = useConversations(userId);
  const { 
    isRecording, 
    transcript, 
    error: recognitionError,
    startRecording, 
    stopRecording,
    resetTranscript 
  } = useSpeechRecognition();
  
  const [personName, setPersonName] = useState<string>('');
  const [manualTranscript, setManualTranscript] = useState<string>('');
  const [showSuccess, setShowSuccess] = useState<boolean>(false);
  const [permissionError, setPermissionError] = useState<string>('');

  useEffect(() => {
    if (transcript) {
      setManualTranscript(transcript);
    }
  }, [transcript]);

  const handleStartRecording = async (): Promise<void> => {
    setPermissionError('');
    setShowSuccess(false);
    
    try {
      await startRecording();
    } catch (err) {
      const error = err as Error;
      setPermissionError(error.message || 'Unable to access microphone');
    }
  };

  const handleStopRecording = (): void => {
    stopRecording();
  };

  const handleSave = (): void => {
    if (!manualTranscript.trim()) {
      setPermissionError('Please add some conversation notes before saving');
      return;
    }

    const now = new Date();
    const summary = generateSummary(manualTranscript, personName, userName);
    const topics = extractTopics(manualTranscript);

    addConversation({
      id: Date.now().toString(),
      date: now.toISOString().split('T')[0],
      time: now.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }),
      personName: personName.trim() || undefined,
      summary,
      transcript: manualTranscript,
      topics,
    });

    // Reset form
    setPersonName('');
    setManualTranscript('');
    resetTranscript();
    setShowSuccess(true);
    
    setTimeout(() => setShowSuccess(false), 3000);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <div className="h-12 w-12 bg-gradient-to-br from-pink-500 to-rose-500 rounded-full flex items-center justify-center">
          <Mic className="h-6 w-6 text-white" />
        </div>
        <h2 className="text-3xl md:text-4xl font-bold bg-gradient-to-r from-pink-600 to-rose-600 bg-clip-text text-transparent">
          Record a Conversation
        </h2>
      </div>

      {/* Error Messages */}
      {(permissionError || recognitionError) && (
        <Alert className="border-4 border-red-400 bg-gradient-to-r from-red-50 to-rose-50 shadow-lg">
          <AlertCircle className="h-6 w-6 text-red-600" />
          <AlertDescription className="text-xl md:text-2xl text-red-800 ml-2">
            <strong>Microphone Issue:</strong> {permissionError || recognitionError}
            <div className="mt-4 space-y-2 text-lg bg-white/50 p-4 rounded-lg">
              <p>• Check if another app is using your microphone</p>
              <p>• Go to Settings → Permissions → Allow microphone access</p>
              <p>• Try refreshing the page</p>
            </div>
          </AlertDescription>
        </Alert>
      )}

      {/* Success Message */}
      {showSuccess && (
        <Alert className="border-4 border-green-400 bg-gradient-to-r from-green-50 to-emerald-50 shadow-lg animate-in slide-in-from-top duration-500">
          <CheckCircle2 className="h-6 w-6 text-green-600" />
          <AlertDescription className="text-xl md:text-2xl text-green-800 ml-2 font-semibold">
            Conversation saved successfully! 🎉
          </AlertDescription>
        </Alert>
      )}

      {/* Recording Control */}
      <Card className="border-0 shadow-2xl bg-gradient-to-br from-pink-50 to-purple-50 overflow-hidden">
        <CardContent className="p-8">
          <div className="flex flex-col items-center space-y-6">
            <div className="relative">
              {isRecording && (
                <div className="absolute inset-0 animate-ping">
                  <div className="h-40 w-40 md:h-48 md:w-48 rounded-full bg-red-400 opacity-75"></div>
                </div>
              )}
              <Button
                size="lg"
                onClick={isRecording ? handleStopRecording : handleStartRecording}
                className={`relative h-40 w-40 md:h-48 md:w-48 rounded-full text-white font-bold text-2xl border-4 shadow-2xl transform transition-all duration-300 hover:scale-110 ${
                  isRecording 
                    ? 'bg-gradient-to-br from-red-500 to-rose-600 hover:from-red-600 hover:to-rose-700 border-red-300 animate-pulse' 
                    : 'bg-gradient-to-br from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 border-pink-300'
                }`}
              >
                {isRecording ? (
                  <Square className="h-20 w-20" />
                ) : (
                  <Mic className="h-20 w-20" />
                )}
              </Button>
            </div>
            <p className="text-2xl md:text-3xl font-bold text-center">
              {isRecording ? (
                <span className="flex items-center gap-2">
                  <span className="h-3 w-3 bg-red-500 rounded-full animate-pulse"></span>
                  Recording... Tap to stop
                </span>
              ) : (
                'Tap to start recording'
              )}
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Conversation Details */}
      <div className="space-y-6">
        <Card className="border-0 shadow-xl bg-gradient-to-br from-purple-50 to-blue-50">
          <CardContent className="p-6 space-y-6">
            <div className="space-y-3">
              <Label htmlFor="personName" className="text-2xl md:text-3xl font-bold flex items-center gap-2">
                <User className="h-6 w-6 text-purple-600" />
                Who did you talk with?
                <span className="text-lg font-normal text-gray-500">(Optional)</span>
              </Label>
              <Input
                id="personName"
                type="text"
                value={personName}
                onChange={(e) => setPersonName(e.target.value)}
                placeholder="e.g., Emma, Dr. Smith"
                className="text-xl md:text-2xl h-16 border-4 border-purple-300 focus:border-purple-500 bg-white shadow-md transition-all duration-300"
              />
            </div>

            <div className="space-y-3">
              <Label htmlFor="transcript" className="text-2xl md:text-3xl font-bold flex items-center gap-2">
                <MessageSquare className="h-6 w-6 text-blue-600" />
                Conversation Notes
              </Label>
              <Textarea
                id="transcript"
                value={manualTranscript}
                onChange={(e) => setManualTranscript(e.target.value)}
                placeholder="Type or speak to add notes about your conversation..."
                className="text-xl md:text-2xl min-h-48 border-4 border-blue-300 focus:border-blue-500 bg-white shadow-md transition-all duration-300"
              />
              {isRecording && (
                <div className="flex items-center gap-2 text-lg text-blue-600 bg-blue-100 p-3 rounded-lg animate-pulse">
                  <Sparkles className="h-5 w-5" />
                  <span>Listening... Your words will appear here automatically.</span>
                </div>
              )}
            </div>
          </CardContent>
        </Card>

        <Button
          onClick={handleSave}
          disabled={!manualTranscript.trim()}
          className="w-full h-16 text-2xl md:text-3xl font-bold bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white border-0 shadow-xl transform transition-all duration-300 hover:scale-[1.02] disabled:opacity-50 disabled:hover:scale-100"
        >
          <Save className="h-8 w-8 mr-2" />
          Save Conversation
        </Button>
      </div>
    </div>
  );
}

function generateSummary(transcript: string, personName: string, userName: string): string {
  const name = personName.trim() || 'someone';
  const words = transcript.trim().split(/\s+/);
  const shortTranscript = words.slice(0, 20).join(' ');
  
  if (words.length > 20) {
    return `${userName} talked with ${name}. ${shortTranscript}...`;
  }
  
  return `${userName} talked with ${name}. ${shortTranscript}`;
}

function extractTopics(transcript: string): string[] {
  const commonWords = new Set([
    'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
    'of', 'with', 'by', 'from', 'as', 'is', 'was', 'are', 'were', 'be',
    'been', 'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will',
    'would', 'could', 'should', 'may', 'might', 'can', 'i', 'you', 'he',
    'she', 'it', 'we', 'they', 'my', 'your', 'his', 'her', 'its', 'our',
    'their', 'this', 'that', 'these', 'those', 'about', 'talked', 'said'
  ]);
  
  const words = transcript.toLowerCase()
    .split(/\s+/)
    .filter((word: string) => word.length > 4 && !commonWords.has(word));
  
  const wordCount: Record<string, number> = {};
  words.forEach((word: string) => {
    wordCount[word] = (wordCount[word] || 0) + 1;
  });
  
  const topWords = Object.entries(wordCount)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 3)
    .map(([word]) => word.charAt(0).toUpperCase() + word.slice(1));
  
  return topWords;
}
