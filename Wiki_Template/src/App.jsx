import React, { useState, useEffect } from "react";
import { Routes, Route, useLocation } from "react-router-dom";
import Navbar from "./components/Navbar";
import Footer from "./components/Footer";
import Loading from "./components/Loading";
import ScrollToTop from "./components/ScrollToTop"; // novo componente
import Home from "./pages/Home/Home";
import Sobre from "./pages/Sobre";
import Download from "./pages/Download";
import Equipe from "./pages/Equipe";
import Devlog from "./pages/Devlog";
import Docs from "./pages/Docs";
import Galeria from "./pages/Galeria";
import Teste from "./pages/Teste";
import Erro from "./pages/Erro";

function App() {
  const location = useLocation();
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setLoading(true);
    const timeout = setTimeout(() => setLoading(false), 200);
    return () => clearTimeout(timeout);
  }, [location]);

  return (
    <>
      <Navbar />
      <ScrollToTop />
      <main className="container my-5">
        {loading ? (
          <Loading />
        ) : (
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
        )}
      </main>
      <Footer />
    </>
  );
}

export default App;
