# Overview

This is a React Native mobile application built with Expo for an IT Service Management (ITSM) ticketing system. The app provides a comprehensive platform for managing support tickets with role-based access control, allowing both admins and agents to create, view, and manage tickets efficiently. The application features authentication, ticket management with different views, detailed ticket information, commenting system, and user profiles.

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## Frontend Architecture
- **Framework**: React Native with Expo SDK (v53.0.22)
- **Navigation**: React Navigation with stack and bottom tab navigation patterns
- **State Management**: React hooks and context for local state management
- **UI Components**: Custom components with React Native base components
- **Platform Support**: Cross-platform mobile application (iOS and Android)

## Authentication & Authorization
- **Provider**: Supabase Auth for user authentication
- **Methods**: Email/password authentication
- **Session Management**: Automatic token refresh and persistent sessions
- **Role-based Access**: Admin and Agent roles with different permissions and views

## Data Architecture
- **Database**: Supabase (PostgreSQL-based backend-as-a-service)
- **Real-time Features**: Supabase real-time subscriptions for live updates
- **Data Models**: 
  - Users/Profiles with role-based permissions
  - Tickets with status, priority, assignment, and categorization
  - Comments system for ticket collaboration
  - File attachments support

## Screen Architecture
- **Tab Navigation**: Bottom tab navigator for main app sections
- **Stack Navigation**: Nested stack navigation for detailed views
- **Main Screens**:
  - All Tickets (admin view)
  - My Tickets (agent-specific view)
  - Create Ticket form
  - Ticket Details with full information and actions
  - User Profile with statistics

## API Integration
- **Primary Backend**: Supabase client for all data operations
- **External APIs**: Configured for multiple AI services (OpenAI, Gemini, Anthropic, Perplexity) for potential future features
- **Real-time Updates**: WebSocket connections for live ticket updates

## Development Environment
- **Build System**: Expo CLI with webpack for web builds
- **Environment Management**: JSON-based environment configuration
- **Code Organization**: Feature-based folder structure with screens, components, and utilities

# External Dependencies

## Backend Services
- **Supabase**: Primary backend-as-a-service providing authentication, database, and real-time features
- **Database**: PostgreSQL through Supabase with user profiles, tickets, and comments tables

## Third-party Libraries
- **@react-navigation/native**: Navigation framework for React Native
- **@react-navigation/stack**: Stack navigation component
- **@react-navigation/bottom-tabs**: Bottom tab navigation component
- **@supabase/supabase-js**: Official Supabase JavaScript client
- **@react-native-async-storage/async-storage**: Local storage for React Native
- **react-native-url-polyfill**: URL polyfill for React Native environment

## Development Tools
- **Expo**: Development platform and toolchain
- **Babel**: JavaScript compiler with Expo preset
- **React Native Web**: Web compatibility layer

## Future Integration APIs
- **OpenAI API**: Configured for potential AI-powered features
- **Google Gemini API**: Alternative AI service integration
- **Anthropic API**: Claude AI service for advanced features
- **Perplexity API**: Search and knowledge AI capabilities