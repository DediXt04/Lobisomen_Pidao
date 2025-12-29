import React from "react";
import { Routes, Route } from "react-router-dom";
import Navbar from "./components/Navbar";
import Footer from "./components/Footer";
import Home from "./pages/Home/Home";
import Sobre from "./pages/Sobre";
import Equipe from "./pages/Equipe";
import Devlog from "./pages/Devlog";
import Docs from "./pages/Docs";
import Galeria from "./pages/Galeria";
import Teste from "./pages/Teste"


function App() {
  return (
    <>
      <Navbar />
      <main className="container my-5">
        <Routes>
          <Route path="/"         element={<Home />} />
          <Route path="/sobre"    element={<Sobre />} />
          <Route path="/equipe"   element={<Equipe />} />
          <Route path="/devlog"   element={<Devlog />} />
          <Route path="/docs"     element={<Docs />} />
          <Route path="/galeria"  element={<Galeria />} />
          <Route path="/teste"    element={<Teste/>}/>         
        </Routes>
      </main>
      <Footer />
    </>
  );
}

export default App;
