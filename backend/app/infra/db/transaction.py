"""트랜잭션 유틸 스텁."""

from contextlib import contextmanager
from collections.abc import Iterator

from sqlalchemy.orm import Session


@contextmanager
def transactional(db: Session) -> Iterator[Session]:
    """예외 시 롤백, 정상 시 커밋하는 트랜잭션 컨텍스트."""
    try:
        yield db
        db.commit()
    except Exception:
        db.rollback()
        raise
