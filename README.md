# Offline-First Todo App Architecture

![Architecture](https://github.com/user-attachments/assets/00f02015-0221-49bb-b50c-42f69dc7777e)

## App Preview

<p align="center">
  <img src="https://github.com/user-attachments/assets/YOUR_FIRST_IMAGE_ID" width="260"/>
  <img src="https://github.com/user-attachments/assets/YOUR_SECOND_IMAGE_ID" width="260"/>
</p>

## Overview

This architecture follows an offline-first pattern:

- Local database is the source of truth
- UI never waits for network
- Outbox queue handles retries
- Supabase handles sync + realtime
- Riverpod manages reactive state
