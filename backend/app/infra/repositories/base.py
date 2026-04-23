"""리포지토리 공통 베이스."""

from sqlalchemy.orm import Session


class BaseRepository:
    """SQLAlchemy 세션을 공통으로 보관하는 베이스 리포지토리."""

    def __init__(self, db: Session) -> None:
        self.db = db
