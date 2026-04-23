"""v1 API 라우터 집계."""

from fastapi import APIRouter

from app.api.v1 import health
from app.api.v1.pas.router import router as pas_router
from app.api.v1.sas.router import router as sas_router

api_router = APIRouter()
api_router.include_router(health.router)
api_router.include_router(pas_router, prefix="/pas")
api_router.include_router(sas_router, prefix="/sas")
