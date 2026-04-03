"""콘솔에서 `enerbrain-serve`로 개발 서버 실행."""

import uvicorn


def main() -> None:
    """가상환경 활성화 후 프로젝트 루트(backend)에서 enerbrain-serve 실행."""
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
    )
