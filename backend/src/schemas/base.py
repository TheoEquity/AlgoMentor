from pydantic import BaseModel


class APIModel(BaseModel):
    model_config = {
        'from_attributes': True,
        'populate_by_name': True,
    }
