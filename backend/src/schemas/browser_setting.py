from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class BrowserSettingsBase(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    headless: bool = True
    executable_path: str = ''
    viewport_width: int = Field(default=1280, ge=800, le=3840)
    viewport_height: int = Field(default=720, ge=600, le=2160)
    timeout_seconds: int = Field(default=30, ge=5, le=300)
    user_data_dir: str = ''
    proxy_url: str = ''


class BrowserSettingsUpdate(BrowserSettingsBase):
    pass


class BrowserSettings(BrowserSettingsBase):
    id: int
    updated_at: str
