# Offline-First Todo App Architecture

![Architecture](https://github.com/user-attachments/assets/00f02015-0221-49bb-b50c-42f69dc7777e)

## Overview

This architecture follows an offline-first pattern:

- Local database is the source of truth
- UI never waits for network
- Outbox queue handles retries
- Supabase handles sync + realtime
- Riverpod manages reactive state

## Architecture Diagram

