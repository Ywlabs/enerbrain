"""SAS(Site Access Service) 라우터 집계."""

from fastapi import APIRouter, Depends

from app.api.v1.sas import forecast
from app.dependencies import require_sas_api_key

router = APIRouter(tags=["SAS"], dependencies=[Depends(require_sas_api_key)])
router.include_router(forecast.router)
