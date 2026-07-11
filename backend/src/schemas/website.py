from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class CareerSiteListItem(BaseModel):
    id: int
    company_name: str
    url: str
    notes: str | None = None
    industry_category: str = ''
    referral_code: str = ''
    account: str = ''
    password: str = ''
    last_scraped_at: str | None = None
    scrape_status: str
    scrape_error: str | None = None
    position_count: int
    created_at: str
    updated_at: str


class CareerSiteCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    company_name: str = Field(min_length=1)
    url: str = Field(min_length=1)
    notes: str = ''
    industry_category: str = ''
    referral_code: str = ''
    account: str = ''
    password: str = ''


class CareerSiteUpdate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    company_name: str | None = None
    url: str | None = None
    notes: str | None = None
    industry_category: str | None = None
    referral_code: str | None = None
    account: str | None = None
    password: str | None = None


class IndustryCategoryItem(BaseModel):
    id: int
    name: str
    sort_order: int
    created_at: str


class IndustryCategoryCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)
    name: str = Field(min_length=1)


class IndustryCategoryUpdate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)
    name: str | None = None
    sort_order: int | None = None
