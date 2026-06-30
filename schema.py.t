"""Strict Pydantic schema for Jira user story quality evaluation.

Designed for OpenAI Structured Outputs:
- every output field is required;
- unknown fields are forbidden;
- bounded metric values use Literal enums;
- the LLM does not calculate final or weighted scores.
"""

from __future__ import annotations

from typing import Any, Literal, TypeAlias

from pydantic import BaseModel, ConfigDict, Field


BinaryScore: TypeAlias = Literal[0, 1]
Scale4Score: TypeAlias = Literal[1, 2, 3, 4]
StoryPointEstimate: TypeAlias = Literal[1, 2, 3, 5, 8, 13]
AcceptanceCriteriaCount: TypeAlias = Literal[
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
    10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
    20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
    30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
    40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
]


class StrictBaseModel(BaseModel):
    """Base model for strict Structured Outputs parsing."""

    model_config = ConfigDict(
        extra="forbid",
        strict=True,
        str_strip_whitespace=True,
    )


class FormatStoryUserStoryDescription(StrictBaseModel):
    rationale: str = Field(
        ...,
        description=(
            "Concise explanation for the format_story.user_story_description scores. "
            "Mention short evidence from the raw Jira ticket body when present. "
            "Do not include chain-of-thought."
        ),
    )
    presence_of_who: BinaryScore = Field(
        ...,
        description=(
            "Binary score. Return 1 if the story explicitly identifies an actor, user, "
            "role, persona, stakeholder, or system user. Return 0 if missing, unclear, "
            "or only implied."
        ),
    )
    presence_of_what: BinaryScore = Field(
        ...,
        description=(
            "Binary score. Return 1 if the story clearly states the requested action, "
            "capability, feature, function, or change. Return 0 if missing or vague."
        ),
    )
    presence_of_why: BinaryScore = Field(
        ...,
        description=(
            "Binary score. Return 1 only if user value, business value, benefit, reason, "
            "or intended outcome is explicitly stated. Return 0 if missing, implied, "
            "generic, or unclear."
        ),
    )


class FormatStory(StrictBaseModel):
    user_story_description: FormatStoryUserStoryDescription


class FormatACAcceptanceCriteria(StrictBaseModel):
    rationale: str = Field(
        ...,
        description=(
            "Concise explanation for the format_ac.acceptance_criteria scores. "
            "Mention whether AC items exist and whether Given/When/Then or equivalent "
            "precondition/action/outcome structure is present. Do not include chain-of-thought."
        ),
    )
    count_of_ac: AcceptanceCriteriaCount = Field(
        ...,
        description=(
            "Number of distinct acceptance criteria inferred from the raw Jira ticket body. "
            "Return 0 if no acceptance criteria are clearly provided. Valid range: integer 0 through 50."
        ),
    )
    presence_of_given: BinaryScore = Field(
        ...,
        description=(
            "Binary score. Return 1 if at least one acceptance criterion explicitly uses "
            "Given or clearly describes preconditions/context. Return 0 otherwise."
        ),
    )
    presence_of_when: BinaryScore = Field(
        ...,
        description=(
            "Binary score. Return 1 if at least one acceptance criterion explicitly uses "
            "When or clearly describes a trigger, user action, system action, or event. "
            "Return 0 otherwise."
        ),
    )
    presence_of_then: BinaryScore = Field(
        ...,
        description=(
            "Binary score. Return 1 if at least one acceptance criterion explicitly uses "
            "Then or clearly describes an expected outcome/result. Return 0 otherwise."
        ),
    )


class FormatAcceptanceCriteria(StrictBaseModel):
    acceptance_criteria: FormatACAcceptanceCriteria


class UnderstandabilityUserStoryDescription(StrictBaseModel):
    rationale: str = Field(
        ...,
        description=(
            "Concise explanation for the understandability.user_story_description scores. "
            "Mention coherence, detail level, examples, terminology, and clarity. "
            "Do not include chain-of-thought."
        ),
    )
    story_makes_sense: BinaryScore = Field(
        ...,
        description=(
            "Binary score. Return 1 if the story is logically understandable, coherent, "
            "and not contradictory. Return 0 if fragmented, contradictory, or not understandable."
        ),
    )
    appropriate_level_of_detail: Scale4Score = Field(
        ...,
        description=(
            "Level of detail quality. 1 = almost no useful detail; 2 = limited detail "
            "with major ambiguity; 3 = enough detail for initial understanding; "
            "4 = clear, sufficient, and well-balanced detail."
        ),
    )
    examples_for_complex_requirements: BinaryScore = Field(
        ...,
        description=(
            "Binary score. Return 1 if the requirement is simple and examples are not needed, "
            "or if the requirement is complex and useful examples are provided. Return 0 if "
            "the requirement is complex and examples are missing."
        ),
    )
    consistent_terminology: Scale4Score = Field(
        ...,
        description=(
            "Terminology consistency. 1 = confusing or inconsistent terminology; "
            "2 = noticeable inconsistencies; 3 = mostly consistent terminology; "
            "4 = fully consistent and domain-appropriate terminology."
        ),
    )
    clarity: Scale4Score = Field(
        ...,
        description=(
            "Story writing clarity. 1 = unclear; 2 = partially clear but ambiguous; "
            "3 = mostly clear; 4 = very clear and easy to understand."
        ),
    )


class Understandability(StrictBaseModel):
    user_story_description: UnderstandabilityUserStoryDescription


class SpecificityAcceptanceCriteria(StrictBaseModel):
    rationale: str = Field(
        ...,
        description=(
            "Concise explanation for the specificity.acceptance_criteria scores. "
            "Mention measurability, user/business focus, structure, and language clarity. "
            "Do not include chain-of-thought."
        ),
    )
    specific_and_measurable: BinaryScore = Field(
        ...,
        description=(
            "Binary score. Return 1 if acceptance criteria define observable, measurable, "
            "or verifiable outcomes. Return 0 if vague, subjective, or not objectively measurable."
        ),
    )
    user_focused_tech_agnostic: BinaryScore = Field(
        ...,
        description=(
            "Binary score. Return 1 if acceptance criteria focus on user/business behaviour "
            "and avoid unnecessary technical implementation details. Return 0 if too technical, "
            "implementation-driven, or not user/business focused."
        ),
    )
    logical_structure: Scale4Score = Field(
        ...,
        description=(
            "Acceptance criteria structure. 1 = missing, unstructured, or hard to follow; "
            "2 = weak or inconsistent structure; 3 = mostly logical structure; "
            "4 = clear, ordered, and easy to follow."
        ),
    )
    clear_language: Scale4Score = Field(
        ...,
        description=(
            "Acceptance criteria language quality. 1 = unclear or ambiguous language; "
            "2 = several unclear parts; 3 = mostly clear language; "
            "4 = precise and unambiguous language."
        ),
    )


class Specificity(StrictBaseModel):
    acceptance_criteria: SpecificityAcceptanceCriteria


class TestabilityAndCoverageAcceptanceCriteria(StrictBaseModel):
    rationale: str = Field(
        ...,
        description=(
            "Concise explanation for the testability_and_coverage.acceptance_criteria scores. "
            "Mention edge cases, story alignment, and independent testability. "
            "Do not include chain-of-thought."
        ),
    )
    thoroughness_edge_cases: Scale4Score = Field(
        ...,
        description=(
            "Edge-case and coverage quality. 1 = edge cases, negative paths, exceptions, "
            "or boundary cases are missing; 2 = weak edge-case coverage; "
            "3 = important edge cases are mostly covered; 4 = edge cases and alternative "
            "paths are well covered. Happy-path-only AC should normally score 1 or 2, not 4."
        ),
    )
    ac_aligned_with_story: BinaryScore = Field(
        ...,
        description=(
            "Binary score. Return 1 if the acceptance criteria align with the story description "
            "and validate the intended story outcome. Return 0 if missing, unrelated, contradictory, "
            "or misaligned."
        ),
    )
    testable_independent: Scale4Score = Field(
        ...,
        description=(
            "Independent testability. 1 = not testable or not independently verifiable; "
            "2 = partially testable; 3 = mostly testable; 4 = clearly and independently testable."
        ),
    )


class TestabilityAndCoverage(StrictBaseModel):
    acceptance_criteria: TestabilityAndCoverageAcceptanceCriteria


class ScopeUserStoryDescription(StrictBaseModel):
    rationale: str = Field(
        ...,
        description=(
            "Concise explanation for the scope.user_story_description score. Mention boundaries, "
            "inclusions, exclusions, assumptions, and dependencies when visible. "
            "Do not include chain-of-thought."
        ),
    )
    clear_scope_boundaries: Scale4Score = Field(
        ...,
        description=(
            "Scope boundary quality. 1 = scope is unclear or open-ended; "
            "2 = partially bounded but still ambiguous; 3 = mostly clear with minor missing "
            "assumptions or exclusions; 4 = clear boundaries, inclusions, exclusions, and assumptions."
        ),
    )


class Scope(StrictBaseModel):
    user_story_description: ScopeUserStoryDescription


class SizingStoryAndAcceptanceCriteria(StrictBaseModel):
    rationale: str = Field(
        ...,
        description=(
            "Concise explanation for the sizing.story_and_acceptance_criteria scores. Mention "
            "complexity, ambiguity, dependencies, testing effort, unknowns, and visible evidence. "
            "Do not include chain-of-thought."
        ),
    )
    deliverable_in_one_sprint: BinaryScore = Field(
        ...,
        description=(
            "Binary score. Return 1 if the story appears deliverable within one normal sprint "
            "by a typical delivery team. Return 0 if too large, ambiguous, dependent, or risky."
        ),
    )
    estimated_story_points: StoryPointEstimate = Field(
        ...,
        description=(
            "Fibonacci-style agile story size estimate. Valid values: 1, 2, 3, 5, 8, 13. "
            "Consider complexity, ambiguity, dependencies, testing effort, unknowns, and work amount. "
            "Do not estimate only from text length."
        ),
    )


class Sizing(StrictBaseModel):
    story_and_acceptance_criteria: SizingStoryAndAcceptanceCriteria


class JiraStoryQualityEvaluation(StrictBaseModel):
    """Top-level output object returned by the LLM."""

    reasoning: str = Field(
        ...,
        description=(
            "Concise overall assessment summary of the main strengths and weaknesses of the story "),
    )
    format_story: FormatStory
    format_ac: FormatAcceptanceCriteria
    understandability: Understandability
    specificity: Specificity
    testability_and_coverage: TestabilityAndCoverage
    scope: Scope
    sizing: Sizing


# Rebuild forward references before generating JSON schema, especially when imported dynamically.
JiraStoryQualityEvaluation.model_rebuild()

# Backward/alternative naming alias if the application expects this class name.
JiraStoryQualityAssessmentOutput = JiraStoryQualityEvaluation


def openai_text_format() -> dict[str, Any]:
    """Return a strict JSON schema payload for OpenAI Responses API text.format."""

    return {
        "type": "json_schema",
        "name": "jira_story_quality_evaluation",
        "strict": True,
        "schema": JiraStoryQualityEvaluation.model_json_schema(),
    }


__all__ = [
    "JiraStoryQualityEvaluation",
    "JiraStoryQualityAssessmentOutput",
    "openai_text_format",
]
