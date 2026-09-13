<?php

declare(strict_types=1);

namespace Edpex\Admission\Middleware;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface as Handler;
use Slim\Psr7\Response as SlimResponse;

/**
 * Reuses apiAuthUser() (app/api_auth.php, extracted from api/index.php 2026-08-15) — Bearer JWT
 * first (Next.js/Expo), PHP-session fallback (same-origin web). Does NOT invent a second auth
 * mechanism, per the design doc. Sets the 'auth_user' request attribute RbacMiddleware and the
 * Controllers both read.
 */
final class AuthMiddleware implements MiddlewareInterface
{
    public function process(Request $request, Handler $handler): Response
    {
        $user = apiAuthUser();
        if ($user === null) {
            $response = new SlimResponse(401);
            $response->getBody()->write((string) json_encode(
                ['status' => 'error', 'code' => 'UNAUTHORIZED', 'message' => 'authentication required (Bearer token or session)'],
                JSON_UNESCAPED_UNICODE
            ));
            return $response->withHeader('Content-Type', 'application/json');
        }

        return $handler->handle($request->withAttribute('auth_user', $user));
    }
}
