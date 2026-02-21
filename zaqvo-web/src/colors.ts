// Zaqvo Brand Colors
// Import this file wherever you need the brand colors as JS/TS values.

export const COLORS = {
    primary: '#257eb8',  // Primary Blue
    dark: '#282e52',     // Dark Navy
} as const;

export type BrandColor = keyof typeof COLORS;
