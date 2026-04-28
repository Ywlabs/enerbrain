"""PAS(Platform Admin Service) 라우터 집계."""

from fastapi import APIRouter, Depends

from app.api.v1.pas import analysis_items, analysis_runs, api_services, auth, biz, biz_api_keys, sites, users
from app.dependencies.pas_auth import require_pas_jwt, require_super_admin

router = APIRouter(tags=["PAS"])
router.include_router(auth.router)
router.include_router(users.router, dependencies=[Depends(require_super_admin)])
router.include_router(sites.router, dependencies=[Depends(require_pas_jwt)])
router.include_router(biz.router, dependencies=[Depends(require_pas_jwt)])
router.include_router(analysis_items.router, dependencies=[Depends(require_pas_jwt)])
router.include_router(analysis_runs.router, dependencies=[Depends(require_pas_jwt)])
router.include_router(biz_api_keys.router, dependencies=[Depends(require_pas_jwt)])
router.include_router(api_services.router, dependencies=[Depends(require_pas_jwt)])
