'use client';

import { useState } from 'react';
import type { ReactElement, FormEvent, ChangeEvent } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

interface WelcomeScreenProps {
  onSubmit: (name: string) => void;
}

export function WelcomeScreen({ onSubmit }: WelcomeScreenProps): ReactElement {
  const [name, setName] = useState<string>('');

  const handleSubmit = (e: FormEvent<HTMLFormElement>): void => {
    e.preventDefault();
    if (name.trim()) {
      onSubmit(name.trim());
    }
  };

  const handleChange = (e: ChangeEvent<HTMLInputElement>): void => {
    setName(e.target.value);
  };

  return (
    <div className="min-h-screen bg-white flex items-center justify-center p-4 pt-16">
      <Card className="w-full max-w-2xl border-4 border-black shadow-lg">
        <CardHeader className="text-center space-y-4 pb-8">
          <CardTitle className="text-5xl md:text-6xl font-bold text-black">
            Welcome to MindTrack
          </CardTitle>
          <CardDescription className="text-2xl md:text-3xl text-gray-700">
            Your personal conversation memory assistant
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-8">
            <div className="space-y-4">
              <Label htmlFor="name" className="text-3xl md:text-4xl font-bold text-black">
                What&apos;s your name?
              </Label>
              <Input
                id="name"
                type="text"
                value={name}
                onChange={handleChange}
                placeholder="Enter your name"
                className="text-2xl md:text-3xl h-20 border-4 border-black focus:ring-4 focus:ring-blue-500"
                autoFocus
              />
            </div>
            <Button 
              type="submit" 
              className="w-full h-20 text-3xl md:text-4xl font-bold bg-blue-600 hover:bg-blue-700 text-white border-4 border-black"
              disabled={!name.trim()}
            >
              Get Started
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
