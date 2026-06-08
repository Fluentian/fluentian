import asyncio

from sqlalchemy import select

from app.core.security import hash_password
from app.database import AsyncSessionLocal
from app.models.user import User


async def main():
    async with AsyncSessionLocal() as db:
        result = await db.execute(
            select(User).where(
                User.email.in_(
                    [
                        "superadmin@fluentian.com",
                        "admin@fluentian.com",
                        "teacher@fluentian.com",
                        "student@fluentian.com",
                    ]
                )
            )
        )
        users = result.scalars().all()
        for user in users:
            user.password_hash = hash_password("Fluentian@12345")
            user.email_verified = True
            user.is_active = True
        await db.commit()
        print(f"Updated {len(users)} local admin/staff/student passwords")


if __name__ == "__main__":
    asyncio.run(main())
