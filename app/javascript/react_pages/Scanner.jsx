import React, { useEffect, useState } from "react";

export function Scanner(props) {
  const [readResult, setReadResult] = useState();
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const videoElement = document.querySelector("#reader-video");

    if (!videoElement) return;

    let internalLoading = false;

    const onSuccess = async (qrcodeIdentifier) => {
      if (internalLoading) return;
      internalLoading = true;
      if (readResult || loading) return;

      setLoading(true);

      try {
        const response = await axios.get(
          `/api/v1/qrcodes/${qrcodeIdentifier}/scan?session_identifier=${props.sessionIdentifier}`
        );
        setReadResult(response.data);
      } catch {
        setReadResult({
          result: false,
          error: "Erro de requisição",
          error_details: `Status ${response.status}`
        });
      }

      internalLoading = true;

      setLoading(false);
    };

    const onFailure = (error) => {};

    const qrScanner = new props.scanner(videoElement, onSuccess, onFailure);

    qrScanner.start();
  }, [readResult]);

  return (
    <div className="main-div vh-100 w-100 position-relative bg-dark">
      {!readResult ? (
        <div className="flex column center vh-100">
          <div className="h-20 flex center around">
            <div>
              <p className="fs-24 fw-700 text-center m-0 text-white">
                Controle de entrada
              </p>
              <p className="fs-24 fw-700 text-center m-0 text-white">
                {props.eventName}
              </p>
            </div>
          </div>
          <video id="reader-video" className="w-100 h-80 p-5"></video>
        </div>
      ) : (
        <div id="result-div" className="w-100 h-100">
          {readResult.result ? (
            <div className="w-100 h-100 bg-success flex center around">
              <div className="h-50 w-50 flex column center around">
                <i class="fas fa-check-circle text-white fs-160"></i>
                <p
                  className="btn btn-dark w-100"
                  onClick={() => {
                    setReadResult(null);
                  }}
                >
                  Próximo
                </p>
              </div>
            </div>
          ) : (
            <div className="w-100 h-100 bg-danger flex center around">
              <div className="h-50 w-50 flex column center around">
                <i class="fas fa-times-circle text-white fs-160"></i>
                <p className="m-0 text-white fs-24 text-center fw-700">
                  {readResult.error}
                </p>
                <p className="m-0 text-white fs-18 text-center">
                  {readResult.error_details}
                </p>
                <p
                  className="btn btn-dark w-100"
                  onClick={() => {
                    setReadResult(null);
                  }}
                >
                  Próximo
                </p>
              </div>
            </div>
          )}
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
