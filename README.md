# Offline-First Todo App Architecture

![Architecture](https://github.com/user-attachments/assets/00f02015-0221-49bb-b50c-42f69dc7777e)

## App Preview

<p align="center">
  <img 
    src="https://github.com/user-attachments/assets/93d6f405-8d3f-4431-ba59-aa8b6ff0278b" 
    width="260"
    alt="Completed Tasks Screen"
  />

  <img 
    src="https://github.com/user-attachments/assets/1d89bee5-6905-49f9-adff-c79de5110b68" 
    width="260"
    alt="Active Tasks Screen"
  />
</p>

## Overview

This architecture follows an offline-first pattern:

- Local database is the source of truth
- UI never waits for network
- Outbox queue handles retries
- Supabase handles sync + realtime
- Riverpod manages reactive state
