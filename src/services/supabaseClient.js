import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://xapznuhizkphoirxnkus.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'sb_publishable_F9U-JWDjVlgCiIvQJd_xkA_7lQYWP73';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
