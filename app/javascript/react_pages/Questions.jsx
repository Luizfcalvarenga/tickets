import React, { useState } from "react";
import ReactDOM from "react-dom";

export function Questions(props) {
  const [questions, setQuestions] = useState(props.questions);
  console.log(props.questions)

  const addQuestion = () => {
    setQuestions([
      ...questions,
      {
        prompt: "",
        kind: "multiple_choice",
        order: questions.length,
        optional: false,
        options: [],
      },
    ]);
  };

  const addQuestionOption = (questionIndex) => {
    const currentQuestions = [...questions];

    const editedQuestion = currentQuestions[questionIndex];

    editedQuestion.options = [...editedQuestion.options, ""];

    setQuestions(currentQuestions);
  };

  const removeQuestionOption = (questionIndex, questionOrderIndex) => {
    const currentQuestions = [...questions];

    const editedQuestion = currentQuestions.find(
      (question) => question.order === questionIndex
    );

    console.log(editedQuestion)

    editedQuestion.options.splice(questionOrderIndex, 1);

    setQuestions(currentQuestions);
  };

  const handleQuestionChange = (field, value, questionOrder) => {
    const currentQuestions = [...questions];

    const editedQuestion = currentQuestions.find(
      (question) => question.order === questionOrder
    );

    editedQuestion[field] = value;

    setQuestions(currentQuestions);
  };

  const handleQuestionOptionalToggle = (questionIndex) => {
    const currentQuestions = [...questions];

    const editedQuestion = currentQuestions[questionIndex];

    editedQuestion.optional = !editedQuestion.optional;

    setQuestions(currentQuestions);
  };

  const handleQuestionOptionChange = (
    value,
    questionIndex,
    questionOptionIndex
  ) => {
    const currentQuestions = [...questions];

    const editedQuestion = currentQuestions[questionIndex];

    editedQuestion.options[questionOptionIndex] = value;

    setQuestions(currentQuestions);
  };

  const removeQuestion = (questionIndex) => {
    const currentQuestions = [...questions];

    currentQuestions.splice(questionIndex, 1);

    setQuestions(currentQuestions);
  };

  const restoreErrorForField = (field, questionFormIdentifier) => {
    if (!props.errors || !props.errors.questions) return;

    const question = props.errors.questions.find(
      (eb) => eb.index == questionFormIdentifier
    );

    if (!question) return;

    const questionErrors = question.error;
    const error =
      questionErrors && questionErrors[field] && questionErrors[field][0];

    return (
      <div className="text-danger">
        <p>{error}</p>
      </div>
    );
  };

  return (
    <div className="">
      <p className="m-0 info-text p-4 br-8 mb-5">
        <i className="fa fa-info-circle mx-3"></i>Lembre-se que as perguntas de
        Nome Completo, CPF e CEP já estão habilitadas por padrão e não precisam
        ser criadas aqui.
      </p>

      {questions.map((question, questionIndex) => {
        return (
          <div key={question.id || question.order} className="mb-4">
            <div className="p-4 bg-dark my-4">
              <div className="flex center gap-24">
                <h3>Pergunta {question.order + 1}</h3>
                <p
                  className="btn btn-danger w-20 text-center text-white"
                  onClick={() => removeQuestion(questionIndex)}
                >
                  <i className="fa fa-trash"></i>
                  <span className="px-3">Remover</span>
                </p>
              </div>
              <div className="flex center between gap-24">
                <input
                  type="hidden"
                  name="questions[][form_identifier]"
                  value={questionIndex}
                />
                <input
                  type="hidden"
                  name="questions[][id]"
                  value={question.id}
                />
                <input
                  type="hidden"
                  name="questions[][order]"
                  value={question.order}
                />
                <div className="my-2 f-50">
                  <input
                    className="form-control my-2 f-50"
                    type="text"
                    name="questions[][prompt]"
                    placeholder="Texto da pergunta"
                    value={question.prompt}
                    onChange={(e) =>
                      handleQuestionChange(
                        "prompt",
                        e.target.value,
                        question.order
                      )
                    }
                  />
                  {restoreErrorForField("prompt", questionIndex)}
                </div>
                <select
                  name="questions[][kind]"
                  id=""
                  className="f-20"
                  value={question.kind}
                  onChange={(e) =>
                    handleQuestionChange("kind", e.target.value, question.order)
                  }
                >
                  <option value="multiple_choice" selected>
                    Múltipla escolha
                  </option>
                  <option value="open">Aberta</option>
                </select>
                {restoreErrorForField("kind", questionIndex)}
                <div className="flex align-items-center gap-12 my-3 f-20">
                  <input
                    type="checkbox"
                    name="questions[][optional]"
                    checked={question.optional}
                    value={question.optional}
                    onChange={() => handleQuestionOptionalToggle(questionIndex)}
                  />
                  <span className="text-white">Pergunta opcional</span>
                </div>
              </div>
              {question.kind === "multiple_choice" && (
                <div>
                  {question.options &&
                    question.options.map(
                      (questionOption, questionOptionIndex) => {
                        return (
                          <div className="flex center">
                            <input
                              className="form-control my-2 f-90"
                              type="text"
                              name="questions[][options][]"
                              value={questionOption}
                              onChange={(e) =>
                                handleQuestionOptionChange(
                                  e.target.value,
                                  questionIndex,
                                  questionOptionIndex
                                )
                              }
                              placeholder="Texto da opção"
                            />
                            <i
                              className="fa fa-trash f-10 text-center clickable"
                              onClick={() =>
                                removeQuestionOption(
                                  questionIndex,
                                  questionOptionIndex
                                )
                              }
                            ></i>
                          </div>
                        );
                      }
                    )}
                  {restoreErrorForField("options", questionIndex)}
                  <p
                    className="btn btn-success p-3"
                    onClick={() => addQuestionOption(questionIndex)}
                  >
                    <i className="fa fa-plus"></i>
                    <span className="px-3">Adicionar opção de resposta</span>
                  </p>
                </div>
              )}
            </div>
          </div>
        );
      })}
      <p className="btn btn-success text-center" onClick={addQuestion}>
        <i className="fa fa-plus-square"></i>
        <span className="px-3">Adicionar pergunta</span>
      </p>
    </div>
  );
}
