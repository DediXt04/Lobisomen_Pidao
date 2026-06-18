import React, { Suspense, lazy } from "react";
import { Routes, Route } from "react-router-dom";
import Navbar from "./components/Navbar";
import Footer from "./components/Footer";
import Loading from "./components/Loading";
import ScrollToTop from "./components/ScrollToTop";

const Home = lazy(() => import("./pages/Home/Home"));
const Sobre = lazy(() => import("./pages/Sobre"));
const Download = lazy(() => import("./pages/Download"));
const Equipe = lazy(() => import("./pages/Equipe"));
const Devlog = lazy(() => import("./pages/Devlog"));
const Docs = lazy(() => import("./pages/Docs"));
const Galeria = lazy(() => import("./pages/Galeria"));
const Teste = lazy(() => import("./pages/Teste"));
const Erro = lazy(() => import("./pages/Erro"));

function App() {
  return (
    <>
      <Navbar />
      <ScrollToTop />
      <main className="container my-5">
        <Suspense fallback={<Loading />}>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/sobre" element={<Sobre />} />
            <Route path="/download" element={<Download />} />
            <Route path="/equipe" element={<Equipe />} />
            <Route path="/devlog" element={<Devlog />} />
            <Route path="/docs" element={<Docs />} />
            <Route path="/galeria" element={<Galeria />} />
            <Route path="/teste" element={<Teste />} />
            <Route path="*" element={<Erro />} />
          </Routes>
        </Suspense>
      </main>
      <Footer />
    </>
  );
}

export default App;
