"""유닛 오브 워크 스텁."""

from sqlalchemy.orm import Session


class UnitOfWork:
    """트랜잭션 경계를 명시적으로 다루기 위한 유닛 오브 워크."""

    def __init__(self, db: Session) -> None:
        self.db = db

    def commit(self) -> None:
        self.db.commit()

    def rollback(self) -> None:
        self.db.rollback()
