from fastapi import APIRouter

from api.routes.agents import router as agents_router
from api.routes.analysis import router as analysis_router
from api.routes.application import router as application_router
from api.routes.candidate_position import router as candidate_position_router
from api.routes.chat import router as chat_router
from api.routes.position import router as position_router
from api.routes.problems import router as problems_router
from api.routes.resume import router as resume_router
from api.routes.review import router as review_router
from api.routes.submissions import router as submissions_router
from api.routes.system import router as system_router
from api.routes.training import router as training_router
from api.routes.training_plan import router as training_plan_router
from api.routes.website import router as website_router

api_router = APIRouter()
api_router.include_router(system_router)
api_router.include_router(agents_router)
api_router.include_router(analysis_router)
api_router.include_router(application_router)
api_router.include_router(candidate_position_router)
api_router.include_router(chat_router)
api_router.include_router(position_router)
api_router.include_router(problems_router)
api_router.include_router(resume_router)
api_router.include_router(review_router)
api_router.include_router(submissions_router)
api_router.include_router(training_router)
api_router.include_router(training_plan_router)
api_router.include_router(website_router)
