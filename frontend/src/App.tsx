import { useState } from "react";
import reactLogo from "./assets/react.svg";
import viteLogo from "/vite.svg";
import jenkinsLogo from "/jenkins.svg";
import "./App.css";

const { VITE_BUILD_DATE, VITE_BUILD_NUMBER, VITE_BUILD_URL } = import.meta.env;
console.log(import.meta.env);

function App() {
  const [count, setCount] = useState(0);

  return (
    <>
      <div>
        <a href="https://www.jenkins.io/" target="_blank">
          <img src={jenkinsLogo} className="logo" alt="Jenkins logo" />
        </a>
        <a href="https://vitejs.dev" target="_blank">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://react.dev" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>
      <h1>Vite + React</h1>
      <h2>Deployed and built with Jenkins</h2>
      <div>
        <h3>Info about latest build</h3>
        <p>Build date: {VITE_BUILD_DATE}</p>
        <p>Build number: {VITE_BUILD_NUMBER}</p>
        <p>Build URL: {VITE_BUILD_URL}</p>
      </div>
      <div className="card">
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
      </div>
      <p className="read-the-docs">Click on the logos to learn more</p>
    </>
  );
}

export default App;
