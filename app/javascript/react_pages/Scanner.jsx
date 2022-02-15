import React, { useEffect, useState } from "react";

export function Scanner(props) {
  const [readResult, setReadResult] = useState();
  const [loading, setLoading] = useState(false);

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
          `/api/v1/passes/${passIdentifier}/scan`
        );
        setReadResult(response.data);
      } catch {
        setReadResult({
          result: false,
          main_line: "Erro de requisição",
          secondary_line: `Status ${response.status}`,
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
              <p className="fs-48 fw-700 text-center m-0 title">
                Controle de entrada
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
                  {readResult.main_line}
                </p>
                <p className="m-0 text-white fs-18 text-center">
                  {readResult.secondary_line}
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
