<?php

declare(strict_types=1);

namespace Edpex\Admission\Support;

use Psr\Http\Message\ResponseInterface as Response;

/** Same envelope as the rest of the app ({status, data, message, count}) — horizontal reuse
 *  (a trait, not a forced base class) so both Controllers share it without an inheritance chain. */
trait JsonResponseTrait
{
    protected function jsonOk(Response $response, mixed $data, ?int $count = null, int $status = 200): Response
    {
        $payload = ['status' => 'ok', 'data' => $data];
        if ($count !== null) {
            $payload['count'] = $count;
        }
        return $this->writeJson($response, $payload, $status);
    }

    protected function jsonError(Response $response, string $code, string $message, int $status): Response
    {
        return $this->writeJson($response, ['status' => 'error', 'message' => $message, 'code' => $code], $status);
    }

    /** @param array<string,mixed> $payload */
    private function writeJson(Response $response, array $payload, int $status): Response
    {
        $response->getBody()->write((string) json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));
        return $response->withHeader('Content-Type', 'application/json')->withStatus($status);
    }
}
