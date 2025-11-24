'use client';

import { useState, useEffect } from 'react';
import type { Conversation } from '@/types/conversation';

interface UseConversationsReturn {
  conversations: Conversation[];
  addConversation: (conversation: Conversation) => void;
  clearAllConversations: () => void;
}

export function useConversations(userId?: string): UseConversationsReturn {
  const [conversations, setConversations] = useState<Conversation[]>([]);

  const storageKey = userId ? `mindtrack_conversations_${userId}` : 'mindtrack_conversations';

  useEffect(() => {
    if (!userId) {
      setConversations([]);
      return;
    }

    const stored = localStorage.getItem(storageKey);
    if (stored) {
      try {
        const parsed = JSON.parse(stored) as Conversation[];
        setConversations(parsed);
      } catch (error) {
        console.error('Error parsing stored conversations:', error);
        setConversations([]);
      }
    } else {
      setConversations([]);
    }
  }, [userId, storageKey]);

  const addConversation = (conversation: Conversation): void => {
    if (!userId) return;

    setConversations((prev: Conversation[]) => {
      const updated = [...prev, conversation];
      localStorage.setItem(storageKey, JSON.stringify(updated));
      return updated;
    });
  };

  const clearAllConversations = (): void => {
    setConversations([]);
    if (userId) {
      localStorage.removeItem(storageKey);
    }
  };

  return { conversations, addConversation, clearAllConversations };
}
