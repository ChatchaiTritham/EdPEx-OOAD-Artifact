<?php

declare(strict_types=1);

namespace Edpex\Admission\Middleware;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface as Handler;
use Slim\Psr7\Response as SlimResponse;

/**
 * Mirrors api/routes.php's existing [handler, requiresAuth, minRole, capability] tuple convention
 * — expressed as Slim4 route-group middleware instead of an array lookup. Must run AFTER
 * AuthMiddleware (reads the 'auth_user' attribute it sets). Most authenticated read routes rely on
 * PersonAccessPolicy for field-level redaction instead of this capability gate — but GET
 * /profiles/{id} is a deliberate exception (admission/public/index.php): it returns the
 * unredacted full-profile projection, so it carries this same manage_admin gate a mutation route
 * would, on top of the policy check PersonController::profile() still runs internally.
 */
final class RbacMiddleware implements MiddlewareInterface
{
    public function __construct(private readonly string $requiredCapability)
    {
    }

    public function process(Request $request, Handler $handler): Response
    {
        $user = $request->getAttribute('auth_user');
        $roleCode = is_array($user) ? (string) ($user['role_code'] ?? 'viewer') : 'viewer';

        if (!apiUserHasCapability($roleCode, $this->requiredCapability)) {
            $response = new SlimResponse(403);
            $response->getBody()->write((string) json_encode(
                ['status' => 'error', 'code' => 'FORBIDDEN', 'message' => "requires capability: {$this->requiredCapability}"],
                JSON_UNESCAPED_UNICODE
            ));
            return $response->withHeader('Content-Type', 'application/json');
        }

        return $handler->handle($request);
    }
}
