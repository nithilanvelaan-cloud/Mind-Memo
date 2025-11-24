export interface Conversation {
  id: string;
  date: string;
  time: string;
  personName?: string;
  summary: string;
  transcript: string;
  topics?: string[];
}
