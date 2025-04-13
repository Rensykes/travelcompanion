# Repository and Service Layer Refactoring

This document outlines the refactoring done to improve the separation of concerns in the data and application layers of the app.

## Core Principles

1. **Repositories**: Focus on a single database table, exposing CRUD operations specific to that table.
2. **Services**: Build complex business logic using multiple repositories, handling cross-table operations.

## Repository Layer

Repositories are responsible for direct database access for a specific table. They:
- Provide CRUD operations for a single table
- Handle basic database queries, inserts, updates, and deletes
- Do not implement business logic
- Do not have knowledge of other repositories

### Repository Structure

We have implemented three repositories:

#### 1. CountryVisitsRepository
Handles operations on the `country_visits` table:
- `getVisitByCountryCode`: Get a single country visit by its code
- `createCountryVisit`: Create a new country visit entry
- `updateCountryVisit`: Update an existing country visit
- `getAllVisits`: Get all country visits
- `deleteCountryVisit`: Delete a country visit by code

#### 2. LocationLogsRepository
Handles operations on the `location_logs` table:
- `createLocationLog`: Create a new location log
- `getLogById`: Get a single log by ID
- `getLogsByCountryCode`: Get logs for a specific country code
- `getAllLogs`: Get all location logs
- `deleteLog`: Delete a log by ID
- `updateLocationLog`: Update a location log

#### 3. LogCountryRelationsRepository
Handles operations on the `log_country_relations` table (joins):
- `createRelation`: Create a new relation between log and country
- `getRelationsByCountryCode`: Get all relations for a country
- `getRelationsByLogId`: Get all relations for a log
- `deleteRelationsByLogId`: Delete relations for a log
- `deleteRelationsByCountryCode`: Delete relations for a country
- `getLogsByCountryCodeJoin`: Perform a JOIN query to get logs for a country

## Service Layer

Services implement business logic that may span multiple repositories. They:
- Orchestrate calls between different repositories
- Handle complex business rules
- Maintain data integrity across tables
- Provide transaction support for multi-table operations

### Service Structure

We have implemented several services:

#### 1. LocationService
Handles location-related operations that require coordination across multiple tables:
- `logEntry`: Log a new location entry with country relations
- `deleteLogAndUpdateRelations`: Delete a log and its relations, then recalculate stats
- `saveCountryVisitWithDate`: Add a country visit for a specific date
- `recalculateDaysSpent`: Recalculate days spent in a country
- `updateCountryVisit`: Update a country visit record

#### 2. CountryDataService
Handles country-level operations:
- `deleteCountryData`: Delete a country and all its related data

#### 3. DataExportImportService
Handles import/export operations:
- `exportData`: Export location logs to a JSON file
- `importData`: Import location logs and rebuild country visits

## Benefits of the Refactoring

1. **Improved Separation of Concerns**:
   - Repositories focus on database access
   - Services focus on business logic

2. **Better Testability**:
   - Repositories can be mocked for service tests
   - Services can be tested independently

3. **Easier Maintenance**:
   - Changes to database schema only affect related repositories
   - Business logic changes only affect related services

4. **Improved Code Organization**:
   - Clear responsibilities for each component
   - Easier to understand where to find specific functionality

5. **Better Handling of Relationships**:
   - Explicit handling of table relationships through services
   - Cross-table operations are properly encapsulated

## How to Extend

When adding new functionality:

1. If it involves a new table, create a dedicated repository for that table
2. If it involves cross-table operations, extend an existing service or create a new one
3. Keep repositories focused on single-table operations
4. Let services handle the complex workflow and business rules 