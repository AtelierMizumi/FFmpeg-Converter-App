import type { Context } from 'hono';
import { ErrorSchema } from '../services/validator';
import type { DatabaseService } from '../services/database';

export interface ErrorHandlerDependencies {
  db: DatabaseService;
}

/**
 * Handle POST /api/errors
 * Records app crashes and errors with stack traces
 */
export async function handleError(
  c: Context,
  deps: ErrorHandlerDependencies
): Promise<Response> {
  try {
    const body = await c.req.json();

    // Validate request body
    const validationResult = ErrorSchema.safeParse(body);
    if (!validationResult.success) {
      return c.json(
        {
          error: 'Validation failed',
          details: validationResult.error.errors,
        },
        400
      );
    }

    const errorData = validationResult.data;

    // Insert into database
    await deps.db.insertError(errorData);

    return c.json(
      {
        success: true,
        message: 'Error recorded successfully',
      },
      201
    );
  } catch (error) {
    console.error('Error handler error:', error);
    
    return c.json(
      {
        error: 'Internal server error',
        message: error instanceof Error ? error.message : 'Unknown error',
      },
      500
    );
  }
}
