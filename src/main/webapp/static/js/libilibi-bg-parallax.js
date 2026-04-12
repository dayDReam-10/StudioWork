(function () {
    var scene = document.querySelector('.bg-scene');
    if (!scene) return;

    var reduceMotion = false;
    try {
        reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    } catch (e) {
        reduceMotion = false;
    }
    if (reduceMotion) return;

    var targetX = 0;
    var targetY = 0;
    var currentX = 0;
    var currentY = 0;
    var rafId = null;
    var maxOffset = 30;
    var ease = 0.22;
    var baseScale = 1.16;

    function clamp(value, max) {
        if (value > max) return max;
        if (value < -max) return -max;
        return value;
    }

    function render() {
        currentX += (targetX - currentX) * ease;
        currentY += (targetY - currentY) * ease;
        scene.style.transform = 'scale(' + baseScale + ') translate3d(' + currentX.toFixed(2) + 'px,' + currentY.toFixed(2) + 'px,0)';

        if (Math.abs(targetX - currentX) < 0.02 && Math.abs(targetY - currentY) < 0.02) {
            rafId = null;
            return;
        }
        rafId = window.requestAnimationFrame(render);
    }

    function updateStrength() {
        var width = window.innerWidth || 1200;
        if (width < 820) {
            maxOffset = 16;
            ease = 0.17;
            baseScale = 1.1;
        } else if (width < 1280) {
            maxOffset = 22;
            ease = 0.19;
            baseScale = 1.12;
        } else {
            maxOffset = 30;
            ease = 0.22;
            baseScale = 1.16;
        }
    }

    function scheduleRender() {
        if (rafId === null) {
            rafId = window.requestAnimationFrame(render);
        }
    }

    function onMouseMove(e) {
        var w = window.innerWidth || 1;
        var h = window.innerHeight || 1;
        var nx = (e.clientX / w - 0.5) * 2;
        var ny = (e.clientY / h - 0.5) * 2;
        targetX = clamp(nx * maxOffset, maxOffset);
        targetY = clamp(ny * maxOffset, maxOffset);
        scheduleRender();
    }

    function onMouseLeave() {
        targetX = 0;
        targetY = 0;
        scheduleRender();
    }

    updateStrength();
    scene.style.willChange = 'transform';
    scene.style.transform = 'scale(' + baseScale + ') translate3d(0,0,0)';
    window.addEventListener('mousemove', onMouseMove, { passive: true });
    window.addEventListener('mouseleave', onMouseLeave, { passive: true });
    window.addEventListener('resize', updateStrength, { passive: true });
})();
