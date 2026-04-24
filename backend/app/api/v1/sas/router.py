"""SAS(Site Access Service) 라우터 집계."""

from fastapi import APIRouter, Depends

from app.api.v1.sas import forecast, result, service_api
from app.dependencies.sas_auth import require_sas_api_key

router = APIRouter(tags=["SAS"], dependencies=[Depends(require_sas_api_key)])
router.include_router(forecast.router)
router.include_router(result.router)
router.include_router(service_api.router)
