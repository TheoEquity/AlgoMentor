from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file='.env', env_prefix='BYTEHUNTER_')

    app_name: str = 'ByteHunter Backend'
    api_prefix: str = '/api/v1'
    database_url: str = Field(default='sqlite:///./bytehunter.db')
    redis_url: str = 'redis://localhost:6379/0'
    judge0_url: str = 'https://ce.judge0.com'
