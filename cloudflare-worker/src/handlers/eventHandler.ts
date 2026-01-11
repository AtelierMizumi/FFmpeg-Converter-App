import type { Context } from 'hono';
import { BatchEventsSchema, EventSchema } from '../services/validator';
import type { DatabaseService } from '../services/database';

export interface EventHandlerDependencies {
  db: DatabaseService;
}

/**
 * Handle POST /api/events
 * Records a batch of events from the app
 */
export async function handleEvents(
  c: Context,
  deps: EventHandlerDependencies
): Promise<Response> {
  try {
    const body = await c.req.json();

    // Validate request body (batch format)
    const validationResult = BatchEventsSchema.safeParse(body);
    if (!validationResult.success) {
      return c.json(
        {
          error: 'Validation failed',
          details: validationResult.error.errors,
        },
        400
      );
    }

    const { events } = validationResult.data;

    // Validate each individual event
    const validEvents = [];
    const errors = [];

    for (let i = 0; i < events.length; i++) {
      const eventValidation = EventSchema.safeParse(events[i]);
      if (eventValidation.success) {
        validEvents.push(eventValidation.data);
      } else {
        errors.push({
          index: i,
          errors: eventValidation.error.errors,
        });
      }
    }

    // Insert valid events (partial success allowed)
    if (validEvents.length > 0) {
      await deps.db.insertEvents(validEvents);
    }

    // Return response with status
    if (errors.length === 0) {
      return c.json(
        {
          success: true,
          recorded: validEvents.length,
          message: 'All events recorded successfully',
        },
        201
      );
    } else if (validEvents.length > 0) {
      return c.json(
        {
          success: true,
          recorded: validEvents.length,
          failed: errors.length,
          errors: errors,
          message: 'Some events recorded successfully',
        },
        207 // Multi-Status
      );
    } else {
      return c.json(
        {
          success: false,
          recorded: 0,
          failed: errors.length,
          errors: errors,
          message: 'No valid events to record',
        },
        400
      );
    }
  } catch (error) {
    console.error('Event handler error:', error);
    
    return c.json(
      {
        error: 'Internal server error',
        message: error instanceof Error ? error.message : 'Unknown error',
      },
      500
    );
  }
}
