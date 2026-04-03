"""SQLAlchemy 엔진 및 세션 팩토리 (DATABASE_URL 설정 시에만 활성)."""

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, declarative_base, sessionmaker

from app.core.config import settings

Base = declarative_base()

engine = None
SessionLocal: sessionmaker[Session] | None = None

if settings.database_url:
    engine = create_engine(settings.database_url, pool_pre_ping=True)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
