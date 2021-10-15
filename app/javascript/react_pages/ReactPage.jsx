import React from "react";
import ReactDOM from "react-dom";

export function ReactPage(props) {
  return (
    <div className="bg-success vh-40 flex center around p-5 br-8">
      <div>
        <div className="flex around cent">
          <img
            src="https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/React-icon.svg/1280px-React-icon.svg.png"
            className="React-logo mb-5"
            alt="logo"
          />
        </div>
        <h2 className="text-white fs-24 fw-700 text-center">
          Este é um componente React
        </h2>
        <p className="text-white text-center">{props.message}</p>
      </div>
    </div>
  );
}
