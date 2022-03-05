import React, { useState } from "react";
import ReactDOM from "react-dom";

export function Questions(props) {
  const [questions, setQuestions] = useState([]);

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

  const addQuestionOption = (questionOrder) => {
    const currentQuestions = [...questions];

    const editedQuestion = currentQuestions.find(
      (question) => question.order === questionOrder
    );

    editedQuestion.options = [...editedQuestion.options, ""];

    setQuestions(currentQuestions);
  };

  const handleQuestionKindChange = (type, questionOrder) => {
    const currentQuestions = [...questions];

    const editedQuestion = currentQuestions.find(
      (question) => question.order === questionOrder
    );

    editedQuestion.kind = type;

    setQuestions(currentQuestions);
  };

  return (
    <div className="">
      {questions.map((question) => {
        return (
          <div key={question.order} className="mb-4">
            <h3>Pergunta {question.order + 1}</h3>
            <div className="flex center between gap-24">
              <input
                type="hidden"
                name="questions[][order]"
                value={question.order}
              />
              <input
                class="form-control my-2 f-60"
                type="text"
                name="questions[][prompt]"
                placeholder="Texto da pergunta"
              />
              <div>
                <h3>Tipo</h3>
                <select
                  name="questions[][kind]"
                  id=""
                  className="form-select my-2 f-30"
                  onChange={() =>
                    handleQuestionKindChange(e.target.value, question.order)
                  }
                >
                  <option value="multiple_choice" selected>
                    Múltipla escolha
                  </option>
                  <option value="open">Aberta</option>
                </select>
              </div>
              <div className="flex align-items-center gap-12 my-3 f-20">
                <input type="checkbox" name="questions[][optional]" />
                <span className="text-white">Pergunta opcional</span>
              </div>
            </div>
            {question.kind === "multiple_choice" && (
              <div>
                {question.options.map((questionOption) => {
                  return (
                    <input
                      class="form-control my-2"
                      type="text"
                      name="questions[][options][]"
                      placeholder="Texto da opção"
                    />
                  );
                })}
                <p
                  className="btn btn-success"
                  onClick={() => addQuestionOption(question.order)}
                >
                  <i className="fa fa-plus-square"></i>
                  <span className="px-3">Adicionar opção de resposta</span>
                </p>
              </div>
            )}
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
