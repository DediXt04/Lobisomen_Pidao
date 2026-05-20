# Plano Semanal — Entrega 29/06/2026

## Contexto
- **Prazo final**: 29/06/2026 (domingo)
- **Dedicação**: ~10h/semana
- **Meta**: Demo/Beta jogável do início ao fim + site funcional
- **Áudio**: obrigatório (música + efeitos básicos)

## Status Atual

### ✅ Já implementado
- Player (WASD, fome, vida, knockback, invencibilidade)
- Coleta de comida + sistema de fome/vida
- NPCs com paciência e probabilidade
- Inimigos com IA (idle/patrol/chase) + cone de visão (debug)
- Tela de vitória e game over
- Seletor de fases
- Suporte a gamepad
- **Spawner genérico** (DONE)
- **Tela de pausa** (DONE)

### 📋 Falta implementar (guias prontos)
- Desbloqueio de fases (GUIA_DESBLOQUEIO_DE_FASES.md)
- Sistema de estrelas (GUIA_SISTEMA_DE_ESTRELAS.md)
- Menu principal (GUIA_MENU_PRINCIPAL.md)

### 📋 Falta implementar (sem guia ainda)
- Tutorial
- Áudio (música + efeitos sonoros)
- Fazer mais fases
- Ativar stealth real (cone de visão funcional, não só debug)
- Polimento: transições de room, ajustes visuais
- Site: deploy final

---

## Cronograma Semanal

### Semana 1 (20/05 – 25/05): Mecânicas Core
**Foco: Desbloqueio de fases + Botões vitória/derrota**

- [ ] Implementar desbloqueio de fases (seguir GUIA_DESBLOQUEIO_DE_FASES.md)
  - global.fase_desbloqueada + save_progresso.ini
  - Visual de fases trancadas no seletor
  - oVitoria desbloqueia próxima fase
- [ ] Implementar botões horizontais na vitória e game over (seção final do DONE_GUIA_TELA_DE_PAUSA.md)
  - Reiniciar Fase + Sair lado a lado
  - Navegação A/D + gamepad
- [ ] Testar fluxo completo: jogar fase 1 → vencer → fase 2 desbloqueia

### Semana 2 (26/05 – 01/06): Estrelas + Fase Extra
**Foco: Sistema de pontuação + mais conteúdo**

- [ ] Implementar sistema de estrelas (seguir GUIA_SISTEMA_DE_ESTRELAS.md)
  - Criar sprite sEstrela 16×16 (2 frames)
  - Cálculo de pontuação na vitória
  - Salvar melhor resultado no .ini
  - Mostrar estrelas no seletor de fases
- [ ] Criar room_03 (fase 3)
  - Tilemap novo ou variação do existente
  - Configurar Room Creation Code (comidaMax, npcSpawn, tempoFomeMax)
  - Posicionar spawn zones e saída

### Semana 3 (02/06 – 08/06): Menu Principal + Stealth
**Foco: Primeira impressão + gameplay real**

- [ ] Implementar menu principal (seguir GUIA_MENU_PRINCIPAL.md)
  - Room rm_Menu com fundo, título, botões
  - Transição para seletor de fases
  - Set como primeira room do jogo
- [ ] Ativar stealth funcional
  - Cone de visão detecta player de verdade (não só debug)
  - Estado CHASE persegue o player ao detectar
  - Ajustar distância/ângulo de detecção para balanceamento

### Semana 4 (09/06 – 15/06): Áudio
**Foco: Som e imersão**

- [ ] Buscar/criar assets de áudio (sites gratuitos: freesound.org, opengameart.org)
  - Música de fundo (menu, gameplay, vitória, game over) — 3-4 tracks
  - Efeitos: coletar comida, dano, game over, selecionar botão, pausar
- [ ] Implementar sistema de áudio
  - Criar oMusica (persistente) para gerenciar música de fundo
  - audio_play_sound para efeitos nos eventos relevantes
  - Transições suaves entre músicas (audio_sound_gain com fade)
- [ ] Testar volume e balanceamento

### Semana 5 (16/06 – 22/06): Polimento + Site
**Foco: Acabamento visual e site pronto**

- [ ] Polimento do jogo
  - Transições de room (fade in/out ou surface)
  - Ajustar balanceamento de dificuldade das 3 fases
  - Corrigir bugs encontrados durante testes
  - Testar gamepad em todas as telas (menu → seletor → jogo → pausa → vitória/derrota)
- [ ] Finalizar site
  - Atualizar conteúdo com screenshots finais
  - Verificar responsividade e links
  - Deploy (GitHub Pages ou Vercel)

### Semana 6 (23/06 – 29/06): Testes Finais + Entrega
**Foco: QA e build final**

- [ ] Playtest completo do início ao fim (3+ vezes)
  - Fluxo: Menu → Seletor → Fase 1 → Vitória → Fase 2 → ... → Todas as fases
  - Testar todos os game overs (fome e dano)
  - Testar pausa em todas as fases
  - Testar estrelas e save de progresso
- [ ] Corrigir bugs críticos encontrados
- [ ] Build final do GameMaker (Windows .exe ou HTML5)
- [ ] Verificar site deployed e funcional
- [ ] Preparar material de entrega (README, screenshots, link do site)

---

## Prioridades se faltar tempo

Se ficar apertado, cortar nesta ordem (do menos essencial ao mais):

1. **Cortar primeiro**: Polimento visual (transições, partículas)
2. **Cortar segundo**: Fase 3 (entregar só com 2 fases)
3. **Cortar terceiro**: Sistema de estrelas (funcional sem, é "nice to have")
4. **Nunca cortar**: Menu principal, desbloqueio de fases, áudio básico, pausa, site
