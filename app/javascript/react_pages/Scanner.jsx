import React, { useEffect, useState } from "react";

export function Scanner(props) {
  const [readResult, setReadResult] = useState();
  const [loading, setLoading] = useState(false);

  const handleAccessModalClose = () => {
    $("#access-modal").hide();
  };

  useEffect(() => {
    const videoElement = document.querySelector("#reader-video");
    if (!videoElement) return;

    let internalLoading = false;

    const onSuccess = async (passIdentifier) => {
      if (internalLoading) return;
      internalLoading = true;
      if (readResult || loading) return;

      setLoading(true);

      try {
        const response = await axios.get(
          `/api/v1/passes/${passIdentifier}/scan?partner_slug=${props.partnerSlug}`
        );
        setReadResult(response.data);
      } catch {
        setReadResult({
          result: false,
          main_line: "Erro de requisição",
        });
      }

      internalLoading = true;
      setLoading(false);
      window.dispatchEvent(window.reloadUserEvent);
    };

    if (props.passIdentifier) {
      onSuccess(props.passIdentifier);
    } else {
      const qrScanner = new props.scanner(videoElement, onSuccess);

      qrScanner.start();
    }
  }, [readResult]);

  return (
    <div className="main-div vh-100 w-100 position-relative bg-dark">
      {!readResult ? (
        <div className="flex column center vh-100">
          <div className="h-20 flex center around">
            <div>
              <p className="fs-48 fw-700 text-center m-0 title">
                Controle de entrada
              </p>
            </div>
          </div>
          <video id="reader-video" className="w-100 h-80 p-5"></video>
        </div>
      ) : (
        <div id="result-div" className="w-100 h-100">
          <div
            className={`w-100 vh-100 flex center around ${
              readResult.result ? "bg-success" : "bg-danger"
            }`}
          >
            <div className="h-75 w-50 flex column center around">
              <i
                className={`fas text-white fs-160 ${
                  readResult.result ? "fa-check-circle" : "fa-times-circle"
                }`}
              ></i>
              <div className="flex column center around">
                <p className="m-0 text-white fs-26 text-center fw-700">
                  {readResult.pass_name}
                </p>
                {readResult.user_credentials.map((credential) => {
                  return (
                    <p className="m-0 text-white fs-26 text-center fw-700">
                      {credential}
                    </p>
                  );
                })}
              </div>
              <div className="flex column center around">
                <p className="m-0 text-white fs-24 text-center fw-700">
                  {readResult.main_line}
                </p>
                <p className="m-0 text-white fs-18 text-center">
                  {readResult.secondary_line}
                </p>
              </div>
              {props.passIdentifier ? (
                <div>
                  <p
                    className="btn btn-dark w-100"
                    onClick={handleAccessModalClose}
                  >
                    Fechar
                  </p>
                </div>
              ) : (
                <div>
                  <p
                    className="btn btn-dark w-100"
                    onClick={() => {
                      setReadResult(null);
                    }}
                  >
                    Próximo
                  </p>
                </div>
              )}
            </div>
          </div>
          <div className="bg-dark w-100">
            <div className="spacer-100"></div>
            <div className="flex around">
              <div>
                <h1>Informações adicionais</h1>
                <h3>Perguntas e respostas</h3>
                {readResult.question_list.map((question) => {
                  return (
                    <p className="m-0 text-white fs-18">
                      <span className="fw-700">
                        {question.event_question.prompt}
                      </span>
                      : {question.value}
                    </p>
                  );
                })}

                <div className="spacer-50"></div>

                <p className="m-0 text-white fs-18">
                  <span className="fw-700">Passe gerado em</span>:{" "}
                  {readResult.pass_generated_at}
                </p>
                <p className="m-0 text-white fs-18">
                  <span className="fw-700">Valor do passe</span>:{" "}
                  {(readResult.price_in_cents / 100).toLocaleString("pt-BR", {
                    style: "currency",
                    currency: "BRL",
                  })}
                </p>

                <div className="spacer-50"></div>

                <h3>Histórico de acessos anteriores</h3>
                {readResult.access_history.map((access) => {
                  return (
                    <p className="m-0 text-white fs-16">
                      <span className="fw-700">
                        {new Date(access.created_at).toLocaleString("pt-BR")}
                      </span>
                      <span className="px-3"></span>
                      {access.granted_by.email}
                    </p>
                  );
                })}
              </div>
            </div>
            <div className="spacer-100"></div>
          </div>
        </div>
      )}
      {loading && (
        <div id="loading-div" className="flex center around">
          <div className="h-50 w-50 flex column center around">
            <div class="lds-dual-ring"></div>
            <p className="m-0 text-white fs-24">Carregando...</p>
          </div>
        </div>
      )}
    </div>
  );
}
