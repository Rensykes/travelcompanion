# Migration Guide for Repository and Service Refactoring

This document will help you understand the changes made during the repository and service layer refactoring and guide you through any additional steps you might need to take.

## Changes Overview

1. **Repositories have been refactored** to focus on single-table operations:
   - `CountryVisitsRepository`: Only handles the country_visits table
   - `LocationLogsRepository`: Only handles the location_logs table
   - `LogCountryRelationsRepository`: New repository for handling log_country_relations table

2. **Services have been created/refactored** to handle complex multi-table logic:
   - `LocationService`: Handles location logging, country visit updates, and recalculations
   - `CountryDataService`: Handles country-level operations
   - `DataExportImportService`: Updated to use the new repositories and services

3. **Dependency Injection** has been updated to reflect the new structure:
   - All repositories are registered
   - Services are registered with their repository dependencies
   - Cubits and other components are updated to use services where appropriate

## Manual Steps Required

Here are some areas you might need to check and update manually:

### 1. UI Components

If any UI components or screens directly use repositories for data access or updates, they should be updated to use the appropriate service instead.

### 2. Tests

If you have unit or integration tests, they will need to be updated:
- Repository tests should focus on single-table operations
- Service tests should test the complex business logic
- Mock repositories for service tests

### 3. Background Tasks

Background tasks and workers that use repositories directly have been updated to use services:
- `BackgroundTask` has been updated to use the `LocationService`

### 4. New Features

When adding new features:
- For a new table, create a dedicated repository
- For complex operations spanning multiple tables, use or create a service
- Follow the pattern of services using repositories, not the other way around

## Database Structure

The database structure remains unchanged:

1. **CountryVisits Table**
   - `countryCode` (Primary Key): Text
   - `entryDate`: DateTime
   - `daysSpent`: Integer

2. **LocationLogs Table**
   - `id` (Primary Key): Integer (auto-increment)
   - `logDateTime`: DateTime
   - `status`: Text
   - `countryCode`: Text (nullable)

3. **LogCountryRelations Table**
   - `logId`: Integer (Foreign Key to LocationLogs.id)
   - `countryCode`: Text (Foreign Key to CountryVisits.countryCode)
   - Primary Key: Composite (`logId`, `countryCode`)

## Repository Methods

### CountryVisitsRepository
- `getVisitByCountryCode`: Get a single country visit
- `createCountryVisit`: Create a new country visit
- `updateCountryVisit`: Update an existing country visit
- `getAllVisits`: Get all country visits
- `deleteCountryVisit`: Delete a country visit

### LocationLogsRepository
- `createLocationLog`: Create a new location log
- `getLogById`: Get a single log by ID
- `getLogsByCountryCode`: Get logs for a specific country
- `getAllLogs`: Get all location logs
- `deleteLog`: Delete a log by ID
- `updateLocationLog`: Update a location log

### LogCountryRelationsRepository
- `createRelation`: Create a new relation between log and country
- `getRelationsByCountryCode`: Get all relations for a country
- `getRelationsByLogId`: Get all relations for a log
- `deleteRelationsByLogId`: Delete relations for a log
- `deleteRelationsByCountryCode`: Delete relations for a country
- `getLogsByCountryCodeJoin`: Get logs for a country via a join

## Service Methods

### LocationService
- `logEntry`: Log a new location entry
- `deleteLogAndUpdateRelations`: Delete a log and update related data
- `saveCountryVisitWithDate`: Save a country visit with a specific date
- `recalculateDaysSpent`: Recalculate days spent in a country
- `updateCountryVisit`: Update a country visit

### CountryDataService
- `deleteCountryData`: Delete a country and all its related data

### DataExportImportService
- `exportData`: Export location logs to a JSON file
- `importData`: Import location logs and rebuild country visits 