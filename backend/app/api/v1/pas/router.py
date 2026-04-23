"""PAS(Platform Admin Service) 라우터 집계."""

from fastapi import APIRouter

from app.api.v1.pas import projects

router = APIRouter(tags=["PAS"])
router.include_router(projects.router)
