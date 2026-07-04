from fastapi import APIRouter

from api.routes.agents import router as agents_router
from api.routes.analysis import router as analysis_router
from api.routes.chat import router as chat_router
from api.routes.problems import router as problems_router
from api.routes.review import router as review_router
from api.routes.submissions import router as submissions_router
from api.routes.system import router as system_router
from api.routes.training import router as training_router

api_router = APIRouter()
api_router.include_router(system_router)
api_router.include_router(agents_router)
api_router.include_router(analysis_router)
api_router.include_router(chat_router)
api_router.include_router(problems_router)
api_router.include_router(review_router)
api_router.include_router(submissions_router)
api_router.include_router(training_router)
