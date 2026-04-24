"""PAS(Platform Admin Service) 라우터 집계."""

from fastapi import APIRouter

from app.api.v1.pas import analysis_items, analysis_runs, api_services, auth, biz, biz_api_keys, sites, users

router = APIRouter(tags=["PAS"])
router.include_router(auth.router)
router.include_router(users.router)
router.include_router(sites.router)
router.include_router(biz.router)
router.include_router(analysis_items.router)
router.include_router(analysis_runs.router)
router.include_router(biz_api_keys.router)
router.include_router(api_services.router)
